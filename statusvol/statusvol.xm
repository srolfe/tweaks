#import "statusvol.h"
#import <objcipc/objcipc.h>
#import <QuartzCore/QuartzCore.h>

statusvol *svol;
UIInterfaceOrientation orient;
UIColor *statusStyle;
NSString *topBundle;

@interface CPDistributedMessagingCenter : NSObject
	+(id)centerNamed:(id)arg1;
	-(void)runServerOnCurrentThread;
	-(void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
@end

@interface SBApplication{
	id _stateSettings;
}

	-(NSInteger)statusBarStyle;
	-(id)_appInfo;
	-(id)bundleIdentifier;
	-(id)mainScene;
	@property(nonatomic,copy) id _stateSettings;
@end

@interface SpringBoard : UIApplication
	- (SBApplication *)_accessibilityFrontMostApplication;
	- (UIStatusBar *)statusBar;
@end

@interface UIStatusBarForegroundStyleAttributes
	- (UIColor *)tintColor;
@end

@interface UIStatusBarForegroundView
	-(UIStatusBarForegroundStyleAttributes *)foregroundStyle;
@end

@interface UIStatusBar{
	UIStatusBarForegroundView *_foregroundView;
}
	-(UIColor *)foregroundColor;
@end

@interface SBStateSettings
	- (id)objectForStateSetting:(unsigned int)arg1;
@end

// Logs when orientation changes to orient
%hook SBUIController
	
	- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1{
		orient=arg1;
		%orig;
	}
	
%end

// Main hook
%hook SBHUDController
	
	// Modify HUD view on presentation
	- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2{
		if ([svol isEnabled]){
			%orig([self modifyHUD:arg1], arg2);
			
			// Disable parallax - 7.1 fix
			UIView *parallax=MSHookIvar<UIView *>(self,"_hudContentView");
			for (UIMotionEffect *mo in parallax.motionEffects){
				[parallax removeMotionEffect:mo];
			}
		}else{%orig;}
	}
	
	- (void)presentHUDView:(id)arg1{
		if ([svol isEnabled]){
			%orig([self modifyHUD:arg1]);
			
			// Disable Parallax - 7.1 fix
			UIView *parallax=MSHookIvar<UIView *>(self,"_hudContentView");
			for (UIMotionEffect *mo in parallax.motionEffects){
				[parallax removeMotionEffect:mo];
			}
		}else{%orig;}
	}
	
	// Manually re-center HUD view
	- (void)_recenterHUDView{
		if ([svol isEnabled]){
			UIView *HUD = MSHookIvar<UIView *>(self,"_hudView");
			HUD.frame=[self calculateFrame:HUD.frame];
		}else{
			%orig;
		}
	}
	
	// Show time on tear down
	- (void)_tearDown{
		if ([svol isEnabled] && [svol timeTeardownEnabled]){
			[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:YES crossfade:NO crossfadeDuration:0];
		}
	
		%orig;
	}
	
	// HUD manipulation
	%new(@@:@)
	- (id)modifyHUD:(SBHUDView *)view{
		SBHUDView *tmp=view;
		
		if ([svol isEnabled]){
			// Disable parallax effect
			for (UIMotionEffect *mo in tmp.motionEffects){
				[tmp removeMotionEffect:mo];
			}
		
			// Subview manipulation
			for (id t in tmp.subviews){
				// Disable motion effect?
				if ([t respondsToSelector:@selector(removeMotionEffect:)]){
					UIView *tView=(UIView *)t;
					
					for (UIMotionEffect *mo in tView.motionEffects){
						[tView removeMotionEffect:mo];
					}
				}
				
				// Remove backdrop, if available
				if ([NSStringFromClass([t class]) isEqualToString:@"_UIBackdropView"]){
					[t removeFromSuperview];
				}
			}
		
			// Reset frame
			tmp.frame=[self calculateFrame:tmp.frame];
		
			// Hide time
			if ([svol timeTeardownEnabled]){
				[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:NO crossfade:NO crossfadeDuration:0];
			}	
		}
		
		// Return view
		return tmp;
	}
	
	// Read orientation, calculate frame
	%new(@@:@)
	- (CGRect)calculateFrame:(CGRect)baseFrame{
		int width=0;
		
		if (UIInterfaceOrientationIsLandscape(orient)){
			width = [[UIScreen mainScreen] bounds].size.height / 2;
		}else{
			width = [[UIScreen mainScreen] bounds].size.width / 2;
		}
		
		return CGRectMake(
			(
				width
			)-(
				baseFrame.size.width / 2
			)+0.75,
			-126,
			baseFrame.size.width,
			baseFrame.size.height
		);
	}
	
%end

%hook SBHUDView
	
	- (id)_blockColorForValue:(float)arg1{
		UIColor *tmp=(UIColor *)%orig;
		
		if ([svol isEnabled]){
			CGFloat white, alpha;
		
			[tmp getWhite:&white alpha:&alpha];
			[statusStyle getWhite:&white alpha:nil];
		
			tmp = [UIColor colorWithWhite:white alpha:alpha];
		}
		
		return tmp;
	}
	
	- (void)_updateBlockView:(UIView *)arg1 value:(float)arg2 blockSize:(struct CGSize)arg3 point:(struct CGPoint)arg4{
		// Full theme support
		if ([svol isEnabled]){
			// Figure out current step
			int currentStep=(int)([self progress]*16);
			
			[arg1 setFrame:CGRectMake(arg1.frame.origin.x, arg1.frame.origin.y, arg1.frame.size.width, 20.0)];
			
			UIImage *volImage=[svol imageForState:currentStep];
			
			[arg1.layer setContentsGravity:kCAGravityResizeAspect];//kCAGravityResizeAspectFill];
			[arg1.layer setContents:(id)volImage.CGImage];
			[arg1.layer setAnchorPoint:CGPointMake(0.5,0.8)];
			
			for (UIView *tmp in arg1.subviews){
				[tmp.layer setBackgroundColor:CGColorCreateCopyWithAlpha(arg1.layer.backgroundColor,0.00)];
			}
		}
		
		%orig(arg1,arg2,arg3,arg4);
	}
	
%end

@implementation statusvol
	@synthesize prefs, skin;
	
	- (id)init{
		if (self=[super init]){
			// Setup skin store
			self.skin=[[NSDictionary alloc] initWithObjectsAndKeys:[[NSMutableDictionary alloc] init],@"light",[[NSMutableDictionary alloc] init],@"dark",nil];
			
			self.statusColors=[[NSMutableDictionary alloc] init];
			
			// Load our preferences
			[self loadPrefs];
			//[self setupNotifications];
		}
		
		return self;
	}
	
	- (void)recordColor:(NSDictionary *)message{
		[self.statusColors setObject:[message objectForKey:@"color"] forKey:[message objectForKey:@"bundle"]];
		
		NSLog(@"!--- Did get! %@",self.statusColors);
	}
	
	- (NSDictionary *)handleMessageNamed:(NSString *)messageName withUserInfo:(NSDictionary *)userInfo{
		NSLog(@"!-- Did receive notification: %@ %@",messageName,userInfo);
		return nil;
	}
	
	// Did receive preference reload notification
	- (void)loadPrefs{
		[[self prefs] release];
		[[self skin] release];
		
		prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.chewmieser.statusvol.plist"];
		self.skin=[[NSDictionary alloc] initWithObjectsAndKeys:[[NSMutableDictionary alloc] init],@"light",[[NSMutableDictionary alloc] init],@"dark",nil];
	}
	
	// Is StatusVol enabled?
	- (BOOL)isEnabled{
		return ([[self prefs] objectForKey:@"statusvol.enabled"]==nil || [[[self prefs] objectForKey:@"statusvol.enabled"] intValue]==YES);
	}
	
	// Support disabling time-teardown (for statusbar tweaks)
	- (BOOL)timeTeardownEnabled{
		return ([[self prefs] objectForKey:@"statusvol.timeEnabled"]==nil || [[[self prefs] objectForKey:@"statusvol.timeEnabled"] intValue]==YES);
	}
	
	// Get the proper image for the current color and state & cache it
	- (UIImage *)imageForState:(int)state withMode:(NSString *)mode{
		// Default on circled
		NSString *skinName=[[self prefs] objectForKey:@"statusvol.mask"];
		if (skinName==nil) skinName=@"circled";
		
		// If the image isn't cached, cache it
		if ([(NSMutableDictionary *)[[self skin] objectForKey:mode] objectForKey:[@(state) stringValue]] == nil){
			if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/Library/StatusVol/%@/%@/%d.png",skinName,mode,state]] || [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/Library/StatusVol/%@/%@/%d@2x.png",skinName,mode,state]]){
				[(NSMutableDictionary *)[[self skin] objectForKey:mode] setObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/StatusVol/%@/%@/%d.png",skinName,mode,state]] forKey:[@(state) stringValue]];
			}
		}
		
		return (UIImage *)[[[self skin] objectForKey:mode] objectForKey:[@(state) stringValue]];
	
	}
	
	// Get the proper image for the current color and state & cache it
	- (UIImage *)imageForState:(int)state{
		// Figure out the proper color:
		SpringBoard *spring=(SpringBoard *)[UIApplication sharedApplication];
		SBApplication *topApp=[spring _accessibilityFrontMostApplication];
		
		UIColor *sColor;
		
		// We're in an application
		if (topApp!=nil){
			NSString *bun=[topApp bundleIdentifier];
			sColor=(UIColor *)[self.statusColors objectForKey:bun];
			if (sColor==nil) sColor=[UIColor blackColor];
		}else{
			// Inside SpringBoard
			UIStatusBar *springStatus=[spring statusBar];
			UIStatusBarForegroundView *springForeground=MSHookIvar<UIStatusBarForegroundView *>(springStatus,"_foregroundView");
			UIStatusBarForegroundStyleAttributes *springForegroundStyle=[springForeground foregroundStyle];
			sColor=[springForegroundStyle tintColor];
		}
		
		NSLog(@"!--- sColor: %@",self.statusColors);
		
		// We've got the color, now get the mode
		CGFloat white;
		[sColor getWhite:&white alpha:nil];
		if (white>0.5){
			return [self imageForState:state withMode:@"light"];
		}else{
			return [self imageForState:state withMode:@"dark"];
		}
	}
	
	- (void)didUpdateColor:(UIColor *)color{
		statusStyle=color;
	}
	
@end

// Act on the notifications
static void PreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[svol loadPrefs];
}

// Set things up
%ctor {
	svol=[[statusvol alloc] init];
	
	// Handle preference changes
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChanged, CFSTR("com.chewmieser.statusvol.prefs-changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	
	[OBJCIPC registerIncomingMessageFromAppHandlerForMessageName:@"statusVol.didGetColor"  handler:^NSDictionary *(NSDictionary *message) {
		[svol recordColor:message];
	    return nil;
	}];
	
	// Handle color events
	/*CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, GotWhite, CFSTR("statusvol.gotWhite"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, GotBlack, CFSTR("statusvol.gotBlack"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);*/
}