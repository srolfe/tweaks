#import <AudioToolbox/AudioServices.h> // Temporary fix for silent mode vibrate support
#import <QuartzCore/QuartzCore.h>
#import "statusvollite.h"

// Global vars
StatusVol *svol;
bool sVolIsVisible=NO;

// Force hide silent switch HUD - would prefer a better solution here
%hook SBRingerHUDController
	+ (void)activate:(int)arg1{
		[svol _updateSvolLabel:17+arg1 type:1];
	}
%end


// frontMostApplication -> SBApplication -> screenFromSceneID?

// Hook volume change events
%hook VolumeControl
	- (void)_changeVolumeBy:(float)arg1{
		%orig;
		
		int theMode=MSHookIvar<int>(self,"_mode");
		
		if (theMode==0){
			[svol _updateSvolLabel:[self getMediaVolume]*16 type:0];
		}else{
			[svol _updateSvolLabel:[self volume]*16 type:1];
		}
	}
	
	// Force HUDs hidden
	- (_Bool)_HUDIsDisplayableForCategory:(id)arg1{return NO;}
	- (_Bool)_isCategoryAlwaysHidden:(id)arg1{return YES;}
%end

%hook SpringBoard
	- (void)applicationDidFinishLaunching:(id)arg1{
		%orig;
		
		// Create StatusVol inside SpringBoard
		svol=[[StatusVol alloc] init];
	}
%end

// StatusVol needs an auto-rotating UIWindow
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
		[self setHidden:YES]; // Mitigate black box issue
		return YES;
	}
@end
	
@implementation UIView (ColorOfPoint)

- (UIColor *) colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);

    CGContextTranslateCTM(context, -point.x, -point.y);

    [self.layer renderInContext:context];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);

    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];

    return color;
}
@end
	
@implementation StatusVol
	- (id)init{
		self=[super init];
		if (self){
			preferences=[[NSDictionary alloc] init];
			isAnimatingClose=NO;
			svolCloseInterrupt=NO;
			
			[self loadPreferences];
			[self initializeWindow];
			
			hideTimer=nil;
		}
		return self;
	}
	
	- (void)loadPreferences{
		NSMutableDictionary *tmpPrefs;
		
		CFStringRef appID=CFSTR("com.chewmieser.statusvollite");
		CFArrayRef keyList=CFPreferencesCopyKeyList(appID,kCFPreferencesCurrentUser,kCFPreferencesAnyHost);
		if (!keyList){
			tmpPrefs=[[NSMutableDictionary alloc] init];
		}else{
			tmpPrefs=(__bridge NSMutableDictionary *)CFPreferencesCopyMultiple(keyList,appID,kCFPreferencesCurrentUser,kCFPreferencesAnyHost);
			CFRelease(keyList);
		}
		
		// Add missing prefs
		if ([tmpPrefs objectForKey:@"UseSquares"]==nil) [tmpPrefs setObject:@"0" forKey:@"UseSquares"];
		if ([tmpPrefs objectForKey:@"HideIcons"]==nil) [tmpPrefs setObject:@"0" forKey:@"HideIcons"];
		if ([tmpPrefs objectForKey:@"InvertColors"]==nil) [tmpPrefs setObject:@"0" forKey:@"InvertColors"];
		if ([tmpPrefs objectForKey:@"DynamicColors"]==nil) [tmpPrefs setObject:@"0" forKey:@"DynamicColors"];
		if ([tmpPrefs objectForKey:@"DisableBackground"]==nil) [tmpPrefs setObject:@"0" forKey:@"DisableBackground"];
		if ([tmpPrefs objectForKey:@"HideTime"]==nil) [tmpPrefs setObject:@"0" forKey:@"HideTime"];
		if ([tmpPrefs objectForKey:@"AnimationDuration"]==nil) [tmpPrefs setObject:@"0.25" forKey:@"AnimationDuration"];
		if ([tmpPrefs objectForKey:@"StickyDuration"]==nil) [tmpPrefs setObject:@"1.0" forKey:@"StickyDuration"];
		
		preferences=[tmpPrefs copy];
	}
	
	- (void)initializeWindow{
		// Setup window
		CGRect mainFrame=[UIApplication sharedApplication].keyWindow.frame;
		mainFrame.origin.x=0;
		mainFrame.origin.y=-20;
		mainFrame.size.height=20;
		sVolWindow=[[svolWindow alloc] initWithFrame:mainFrame];
		if ([sVolWindow respondsToSelector:@selector(_setSecure:)]) [sVolWindow _setSecure:YES];
		sVolWindow.windowLevel=1058;
		
		mainFrame.origin.y=0;
		
		// Main view controller
		primaryVC=[[UIViewController alloc] init];
		[primaryVC.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		
		// Blur view
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
	
	- (void)_updateSvolLabel:(int)level type:(int)type{
		NSMutableString *timeString=[[NSMutableString alloc] init];
		
		// Test SB Hook
		SpringBoard *SB=(SpringBoard *)[UIApplication sharedApplication];
		SBApplication *SBA=(SBApplication *)[SB _accessibilityFrontMostApplication];
		UIScreen *tmpScreen=(UIScreen *)[SBA _screenFromSceneID:[SBA mainSceneID]];
		UIWindow *tmp=(UIWindow *)[SB _keyWindowForScreen:tmpScreen];
		
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		UIGraphicsBeginImageContext(screenRect.size);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		//[[UIColor blackColor] set];
		//CGContextFillRect(ctx, screenRect);
		[tmp.layer renderInContext:ctx];
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
		
		NSLog(@"!-- keyWindow: %@",tmp);
		//- (id)_keyWindowForScreen:(id)arg1;
		
		
		/*[tmpScreen _enumerateWindowsWithBlock:^(id tmp){
			NSLog(@"!-- Win: %@",tmp);
		}];*/
		
		
		// - (void)_enumerateWindowsWithBlock:( void ( ^ )( id ) )arg1;
		
		//_UIReplicantView *replicant=(_UIReplicantView *)[tmpScreen snapshot];
		
	    /*CGRect screenRect = [[UIScreen mainScreen] bounds];
		UIGraphicsBeginImageContext(screenRect.size);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		//[[UIColor blackColor] set];
		//CGContextFillRect(ctx, screenRect);
		[replicant.layer renderInContext:ctx];
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);*/
		
		// UIApplicationAutomaticSnapshotDefault
		// - (id)_snapshotImageWithImageName:(id)arg1 sceneID:(id)arg2 size:(struct CGSize)arg3 scale:(double)arg4 downscaled:(_Bool)arg5 launchingOrientation:(long long)arg6 originalOrientation:(long long *)arg7 currentOrientation:(long long *)arg8;
		
		//long long ggg;
		//id tmp=[SBA _snapshotImageWithImageName:@"UIApplicationAutomaticSnapshotDefault" sceneID:[SBA mainSceneID] size:CGSizeMake(100,100) scale:1.0 downscaled:NO launchingOrientation:0 originalOrientation:&ggg currentOrientation:&ggg];
		
		//NSLog(@"!-- OMG %@",tmp);
		
		/*UIScreen *tmpScreen=(UIScreen *)[SBA _screenFromSceneID:[SBA mainSceneID]];
		id tmp=[tmpScreen _snapshotExcludingWindows:nil withRect:CGRectMake(0,0,100,100)];
		NSLog(@"!--- omg: %@",tmp);*/
		
		
		//- (id)_defaultPNGForSceneID:(id)arg1 size:(struct CGSize)arg2 scale:(double)arg3 launchingOrientation:(long long)arg4 orientation:(long long *)arg5;
		//- (id)_snapshotExcludingWindows:(id)arg1 withRect:(struct CGRect)arg2;
		
		//_enumerateWindowsWithBlock
		
		/*UIView *tmp=(UIView *)[tmpScreen snapshotViewAfterScreenUpdates:NO];
		
		NSLog(@"!--- theImage: %@",[tmp colorOfPoint:CGPointMake(5,5)]);*/
		
		//NSLog(@"!-- KWFS: %@",[SB _keyWindowForScreen:[UIScreen mainScreen]]);
		
		if ([[preferences objectForKey:@"InvertColors"] intValue]==1){
			[indicatorLabel setTextColor:[UIColor blackColor]];
		
			if ([%c(UIBlurEffect) class]){ // iOS8
				UIBlurEffect *blurEffect=[%c(UIBlurEffect) effectWithStyle:UIBlurEffectStyleExtraLight];
				[blurView _setEffect:blurEffect];
			}else{ // iOS7
				[back removeFromSuperview];
				back=[[%c(_UIBackdropView) alloc] initWithStyle:0];
				[back setAutosizesToFitSuperview:NO];
				[back setFrame:sVolWindow.frame];
				[back setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
				[primaryVC.view insertSubview:back atIndex:0];
			}
		}else{
			[indicatorLabel setTextColor:[UIColor whiteColor]];
		
			if ([%c(UIBlurEffect) class]){ // iOS8
				UIBlurEffect *blurEffect=[%c(UIBlurEffect) effectWithStyle:UIBlurEffectStyleDark];
				[blurView _setEffect:blurEffect];
			}else{ // iOS7
				[back removeFromSuperview];
				back=[[%c(_UIBackdropView) alloc] initWithStyle:1];
				[back setAutosizesToFitSuperview:NO];
				[back setFrame:sVolWindow.frame];
				[back setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
				[primaryVC.view insertSubview:back atIndex:0];
			}
		}
		
		if ([[preferences objectForKey:@"DisableBackground"] intValue]==1){
			[back setAlpha:0.0];
			[blurView setAlpha:0.0];
		}else{
			[back setAlpha:1.0];
			[blurView setAlpha:1.0];
		}
		
		if ([[preferences objectForKey:@"HideTime"] intValue]==1){
			[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:NO crossfade:NO crossfadeDuration:0];
		}
		
		// Silent switch
		if (level==17){
			[timeString appendString:@"S i l e n t"];
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // Temporary silent vibrate fix
		}else{
			// Get the proper system volume when leaving silent mode - doesn't work if "change with buttons" not set
			if (level==18) level=[[%c(VolumeControl) sharedVolumeControl] volume]*16;
			
			// Icons for system vs media volume - if enabled
			if ([[preferences objectForKey:@"HideIcons"] intValue]==0){
				if (type==0){
					[timeString appendString:@"♫  "];
				}else{
					[timeString appendString:@"☎︎  "];
				}
			}
			
			// Make level into string - circles or squares?
			for (int i=0;i<level;i++){
				if ([[preferences objectForKey:@"UseSquares"] intValue]==0){
					[timeString appendString:@"⚫︎"];
				}else{
					[timeString appendString:@"◾︎"];//@"■"];
				}
			}
			
			for (int i=0;i<(16-level);i++){
				if ([[preferences objectForKey:@"UseSquares"] intValue]==0){
					[timeString appendString:@"⚪︎"];
				}else{
					[timeString appendString:@"◽︎"];//@"□"];
				}
			}
		}
		
		// Fix kerning with circles
		NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:timeString];
		if ([[preferences objectForKey:@"UseSquares"] intValue]==0) [attributedString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:-2.0] range:NSMakeRange(0, [timeString length])];
		[indicatorLabel setAttributedText:attributedString];
		
		// Show and set hide timer
		if (!sVolIsVisible || isAnimatingClose){
			// Window adjustments
			if (!isAnimatingClose){
				[sVolWindow fixSvolWindow];
				sVolIsVisible=YES;
				[sVolWindow setHidden:NO];
			}else{
				svolCloseInterrupt=YES;
			}
			
			// Animate entry
			[UIView animateWithDuration:[[preferences objectForKey:@"AnimationDuration"] floatValue] delay:nil options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) animations:^{
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
			} completion:^(BOOL finished){
				// Reset the timer
				svolCloseInterrupt=NO;
				if (hideTimer!=nil) {[hideTimer invalidate]; hideTimer=nil;}
				hideTimer=[NSTimer scheduledTimerWithTimeInterval:[[preferences objectForKey:@"StickyDuration"] floatValue] target:self selector:@selector(hideSvolWindow) userInfo:nil repeats:NO];
			}];
		}else{
			// Reset the timer
			if (hideTimer!=nil) {[hideTimer invalidate]; hideTimer=nil;}
			hideTimer=[NSTimer scheduledTimerWithTimeInterval:[[preferences objectForKey:@"StickyDuration"] floatValue] target:self selector:@selector(hideSvolWindow) userInfo:nil repeats:NO];
		}
	}
	
	- (void)hideSvolWindow{
		// Unset hide timer
		hideTimer=nil;
		
		// Animate hide
		[UIView animateWithDuration:[[preferences objectForKey:@"AnimationDuration"] floatValue] delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) animations:^{
			isAnimatingClose=YES;
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
			isAnimatingClose=NO;
			
			if (finished && !svolCloseInterrupt){
				sVolIsVisible=NO;
				[sVolWindow setHidden:YES];
			
				if ([[preferences objectForKey:@"HideTime"] intValue]==1){
					[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:YES crossfade:NO crossfadeDuration:0];
				}
			}
		}];
	}
	
@end
	
static void PreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (svol!=nil) [svol loadPreferences];
}

%ctor{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChanged, CFSTR("com.chewmieser.statusvollite.prefs-changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	
	if (access("/var/lib/dpkg/info/com.chewmieser.statusvollite.list",F_OK)==-1){
		NSLog(@"[StatusVol 2] This package came from");
	}
}