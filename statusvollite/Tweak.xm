#import <AudioToolbox/AudioServices.h> // Temporary fix for silent mode vibrate support
#import "statusvollite.h"

// Global vars
// Most of these should make their way inside SpringBoard / svolWindow eventually
UILabel *indicatorLabel;
UIVisualEffectView *blurView;
UIViewController *primaryVC;
_UIBackdropView *back;
NSTimer *hideTimer=nil;
svolWindow *sVolWindow;
bool sVolIsVisible=NO;
//_UILegibilityLabel *tmpLabel;

@implementation svolWindow
	// Un-hide after rotation
	- (void)_finishedFullRotation:(id)arg1 finished:(id)arg2 context:(id)arg3{
		[super _finishedFullRotation:arg1 finished:arg2 context:arg3];
		
		[self fixSvolWindow];
		if (sVolIsVisible) [self setHidden:NO]; // Mitigate black box issue
	}
	
	// Fix frame after orientation
	- (void)fixSvolWindow{
		// Reset frame
		long orientation=(long)[[UIDevice currentDevice] orientation];
		CGRect windowRect=self.frame;
		windowRect.origin.x=0;
		windowRect.origin.y=0;
		
		switch (orientation){
			case 1:{
				if (!sVolIsVisible) windowRect.origin.y=-20;
			}break;
			case 2:{
				if (!sVolIsVisible) windowRect.origin.y=20;
			}break;
			case 3:{
				if (!sVolIsVisible) windowRect.origin.x=20;
			}break;
			case 4:{
				if (!sVolIsVisible) windowRect.origin.x=-20;
			}break;
		}
		
		[self setFrame:windowRect];
	}
	
	// Force support auto-rotation. Hide on rotation events
	- (BOOL)_shouldAutorotateToInterfaceOrientation:(int)arg1{
		[self setHidden:YES];
		return YES;
	}
@end

// Force hide silent switch HUD - would prefer a better solution here
%hook SBRingerHUDController
	+ (void)activate:(int)arg1{
		[((SpringBoard *)[UIApplication sharedApplication]) _updateSvolLabel:17+arg1 type:1];
	}
%end

// Hook volume change events
%hook VolumeControl
	- (void)_changeVolumeBy:(float)arg1{
		%orig;
		
		int theMode=MSHookIvar<int>(self,"_mode");
		
		if (theMode==0){
			[((SpringBoard *)[UIApplication sharedApplication]) _updateSvolLabel:[self getMediaVolume]*16 type:0];
		}else{
			[((SpringBoard *)[UIApplication sharedApplication]) _updateSvolLabel:[self volume]*16 type:1];
		}
	}
	
	// Force HUDs hidden
	- (_Bool)_HUDIsDisplayableForCategory:(id)arg1{return NO;}
	- (_Bool)_isCategoryAlwaysHidden:(id)arg1{return YES;}
%end

%hook SpringBoard
	// Setup UIWindow
	- (void)applicationDidFinishLaunching:(id)arg1{
		%orig;
		
		// Setup window
		CGRect mainFrame=[UIApplication sharedApplication].keyWindow.frame;
		mainFrame.origin.x=0;
		mainFrame.origin.y=-20;
		mainFrame.size.height=20;
		sVolWindow=[[svolWindow alloc] initWithFrame:mainFrame];
		if ([sVolWindow respondsToSelector:@selector(_setSecure:)]) [sVolWindow _setSecure:YES];
		sVolWindow.windowLevel=1058;//UIWindowLevelStatusBar+1;
		
		mainFrame.origin.y=0;
		
		// Main view controller
		primaryVC=[[UIViewController alloc] init];
		[primaryVC.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		
		// Blur view //!UIAccessibilityIsReduceTransparencyEnabled()
		if ([%c(UIBlurEffect) class]){
			UIBlurEffect *blurEffect=[%c(UIBlurEffect) effectWithStyle:UIBlurEffectStyleDark];
			blurView=[[%c(UIVisualEffectView) alloc] initWithEffect:blurEffect];
			[blurView setFrame:mainFrame];
			[blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
			[primaryVC.view addSubview:blurView];
		}else{
			back=[[%c(_UIBackdropView) alloc] initWithStyle:1];
			[back setAutosizesToFitSuperview:NO];
			[back setFrame:mainFrame];
			[back setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
			[primaryVC.view addSubview:back];
		}
		
		// STR: 0.3
		
		// Primary: 1,1
		// Secondary: 1 0.45
		// shadowAlpha: 1
		// shadowColor: 0,1
		// shadowCompostingFilterName: darkenSourceOver
		// shadowRadius: 12
		// style: 1
		
		/*_UILegibilitySettings *legSettings=[%c(_UILegibilitySettings) sharedInstanceForStyle:1];
		tmpLabel=[[%c(_UILegibilityLabel) alloc] initWithSettings:legSettings strength:126443839488.000000 string:@"Zebra" font:[UIFont systemFontOfSize:14] options:0];
		[[blurView contentView] addSubview:tmpLabel];*/
		
		// -- Etc
		/*CGRect iconRect=CGRectMake(0,0,20,20);	
		UIGraphicsBeginImageContextWithOptions(iconRect.size,false,0.0);
		UIGraphicsGetCurrentContext();
		[@"🔕" drawAtPoint:CGPointMake(0,0) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName,nil]];
		UIImage *tmp=UIGraphicsGetImageFromCurrentImageContext();
		tmp=[tmp imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		UIGraphicsEndImageContext();
		
		UIImageView *imView=[[UIImageView alloc] initWithImage:tmp];
		imView.tintColor=[UIColor whiteColor];
		[imView setFrame:CGRectMake(0,0,30,30)];
		[primaryVC.view addSubview:imView];*/
		
		// Label
		indicatorLabel=[[UILabel alloc] initWithFrame:mainFrame];
		[indicatorLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[indicatorLabel setTextColor:[UIColor whiteColor]];
		[indicatorLabel setTextAlignment:NSTextAlignmentCenter];
		
		UIFont *labelFont=[UIFont fontWithName:@"Helvetica Neue" size:12];
		[indicatorLabel setFont:labelFont];
		
		[primaryVC.view addSubview:indicatorLabel];
		
		// Make visible and hide window
		sVolWindow.rootViewController=primaryVC;
		[sVolWindow makeKeyAndVisible];
		[sVolWindow setHidden:YES];
	}
	
	// Re-set string + handle hiding
	%new(@v:d)
	- (void)_updateSvolLabel:(int)level type:(int)type{
		NSMutableString *timeString=[[NSMutableString alloc] init];
		
		// Sync and load preferences - there's probably a nicer way to do this... It just slowly evolved into craziness...
		CFPreferencesAppSynchronize(CFSTR("com.chewmieser.statusvollite"));
		
		// > Theming options
		NSNumber *invertColorsSwitch=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("InvertColors"), CFSTR("com.chewmieser.statusvollite")));
		if (invertColorsSwitch==nil) invertColorsSwitch=[NSNumber numberWithInt:0];
		NSNumber *useSquaresSwitch=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("UseSquares"), CFSTR("com.chewmieser.statusvollite")));
		if (useSquaresSwitch==nil) useSquaresSwitch=[NSNumber numberWithInt:0];
		NSNumber *hideIconsSwitch=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("HideIcons"), CFSTR("com.chewmieser.statusvollite")));
		if (hideIconsSwitch==nil) hideIconsSwitch=[NSNumber numberWithInt:0];
		NSNumber *dynamicColorsSwitch=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("DynamicColors"), CFSTR("com.chewmieser.statusvollite")));
		if (dynamicColorsSwitch==nil) dynamicColorsSwitch=[NSNumber numberWithInt:0];
		
		// > Animation options
		NSNumber *animationDuration=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("AnimationDuration"), CFSTR("com.chewmieser.statusvollite")));
		if (animationDuration==nil) animationDuration=[NSNumber numberWithFloat:0.25];
		NSNumber *stickyDuration=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("StickyDuration"), CFSTR("com.chewmieser.statusvollite")));
		if (stickyDuration==nil) stickyDuration=[NSNumber numberWithFloat:2.0];
		
		// > Legacy options
		NSNumber *disableBackgroundSwitch=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("DisableBackground"), CFSTR("com.chewmieser.statusvollite")));
		if (disableBackgroundSwitch==nil) disableBackgroundSwitch=[NSNumber numberWithInt:0];
		NSNumber *hideTimeSwitch=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("HideTime"), CFSTR("com.chewmieser.statusvollite")));
		if (hideTimeSwitch==nil) hideTimeSwitch=[NSNumber numberWithInt:0];
		
		if ([invertColorsSwitch intValue]==1){
			[indicatorLabel setTextColor:[UIColor blackColor]];
		
			if ([%c(UIBlurEffect) class]){
				UIBlurEffect *blurEffect=[%c(UIBlurEffect) effectWithStyle:UIBlurEffectStyleExtraLight];
				[blurView _setEffect:blurEffect];
			}else{
				[back removeFromSuperview];
				back=[[%c(_UIBackdropView) alloc] initWithStyle:0];
				[back setAutosizesToFitSuperview:NO];
				[back setFrame:sVolWindow.frame];
				[back setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
				[primaryVC.view insertSubview:back atIndex:0];
			}
		}else{
			[indicatorLabel setTextColor:[UIColor whiteColor]];
		
			if ([%c(UIBlurEffect) class]){
				UIBlurEffect *blurEffect=[%c(UIBlurEffect) effectWithStyle:UIBlurEffectStyleDark];
				[blurView _setEffect:blurEffect];
			}else{
				[back removeFromSuperview];
				back=[[%c(_UIBackdropView) alloc] initWithStyle:1];
				[back setAutosizesToFitSuperview:NO];
				[back setFrame:sVolWindow.frame];
				[back setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
				[primaryVC.view insertSubview:back atIndex:0];
			}
		}
		
		if ([disableBackgroundSwitch intValue]==1){
			[back setAlpha:0.0];
			[blurView setAlpha:0.0];
		}else{
			[back setAlpha:1.0];
			[blurView setAlpha:1.0];
		}
		
		if ([hideTimeSwitch intValue]==1){
			[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:NO crossfade:NO crossfadeDuration:0];
		}
		
		// Make icons
		/*let colorRect=CGRectMake(0.0, 0.0, 20.0, 20.0)
        UIGraphicsBeginImageContextWithOptions(colorRect.size, false, 0.0)
        let colorContext=UIGraphicsGetCurrentContext();
        UIBezierPath(ovalInRect: colorRect).addClip()
        CGContextSetFillColorWithColor(colorContext, UIColor.blackColor().CGColor);
        CGContextFillRect(colorContext, colorRect);
        let colorImage=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return colorImage
		*/
		
		// Silent switch
		if (level==17){
			[timeString appendString:@"S i l e n t"];
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // Temporary silent vibrate fix
		}else{
			// Get the proper system volume when leaving silent mode - doesn't work if "change with buttons" not set
			if (level==18) level=[[%c(VolumeControl) sharedVolumeControl] volume]*16;
			
			// Icons for system vs media volume - if enabled
			if ([hideIconsSwitch intValue]==0){
				if (type==0){
					[timeString appendString:@"♫  "];
				}else{
					[timeString appendString:@"☎︎  "];
				}
			}
			
			// Make level into string - circles or squares?
			for (int i=0;i<level;i++){
				if ([useSquaresSwitch intValue]==0){
					[timeString appendString:@"⚫︎"];
				}else{
					[timeString appendString:@"◾︎"];//@"■"];
				}
			}
			
			for (int i=0;i<(16-level);i++){
				if ([useSquaresSwitch intValue]==0){
					[timeString appendString:@"⚪︎"];
				}else{
					[timeString appendString:@"◽︎"];//@"□"];
				}
			}
		}
		
		// Fix kerning with circles
		NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:timeString];
		if ([useSquaresSwitch intValue]==0) [attributedString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:-2.0] range:NSMakeRange(0, [timeString length])];
		[indicatorLabel setAttributedText:attributedString];
		
		// Show and set hide timer
		if (!sVolIsVisible){
			// Window adjustments
			[sVolWindow fixSvolWindow];
			sVolIsVisible=YES;
			[sVolWindow setHidden:NO];
			
			// Animate entry
			[UIView animateWithDuration:[animationDuration floatValue] animations:^{
				CGRect windowRect=sVolWindow.frame;
				
				// Animation dependent on orientation
				long orientation=(long)[[UIDevice currentDevice] orientation];
				switch (orientation){
					case 1:windowRect.origin.y=0;break;
					case 2:windowRect.origin.y=0;break;
					case 3:windowRect.origin.x=0;break;
					case 4:windowRect.origin.x=0;break;
				}
				
				[sVolWindow setFrame:windowRect];
			}];
		}
		
		// Reset the timer
		if (hideTimer!=nil) {[hideTimer invalidate]; hideTimer=nil;}
		hideTimer=[NSTimer scheduledTimerWithTimeInterval:[stickyDuration floatValue] target:self selector:@selector(hideSvolWindow) userInfo:nil repeats:NO];
	}
	
	// Handle animations and hiding of the window
	%new(@v:v)
	- (void)hideSvolWindow{
		// Unset hide timer
		hideTimer=nil;
		
		// Sync and load animation duration preference
		CFPreferencesAppSynchronize(CFSTR("com.chewmieser.statusvollite"));
		NSNumber *animationDuration=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("AnimationDuration"), CFSTR("com.chewmieser.statusvollite")));
		if (animationDuration==nil) animationDuration=[NSNumber numberWithFloat:0.25];
		
		NSNumber *hideTimeSwitch=(NSNumber *)((CFNumberRef)CFPreferencesCopyAppValue(CFSTR("HideTime"), CFSTR("com.chewmieser.statusvollite")));
		if (hideTimeSwitch==nil) hideTimeSwitch=[NSNumber numberWithInt:0];
		
		// Animate hide
		[UIView animateWithDuration:[animationDuration floatValue] animations:^{
			CGRect windowRect=sVolWindow.frame;
			
			// Animation dependent on orientation
			long orientation=(long)[[UIDevice currentDevice] orientation];
			switch (orientation){
				case 1:windowRect.origin.y=-20;break;
				case 2:windowRect.origin.y=20;break;
				case 3:windowRect.origin.x=20;break;
				case 4:windowRect.origin.x=-20;break;
			}
			
			[sVolWindow setFrame:windowRect];
		} completion:^(BOOL finished){
			// Hide the window
			sVolIsVisible=NO;
			[sVolWindow setHidden:YES];
			
			if ([hideTimeSwitch intValue]==1){
				[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:YES crossfade:NO crossfadeDuration:0];
			}
		}];
	}
%end
	
/*static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[preferences release];
	CFStringRef appID = CFSTR("com.my.tweak");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		NSLog(@"There's been an error getting the key list!");
		return;
	}
	preferences = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!preferences) {
		NSLog(@"There's been an error getting the preferences dictionary!");
	}
	CFRelease(keyList);
}*/