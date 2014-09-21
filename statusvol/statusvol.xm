#import "statusvol.h"
#import <QuartzCore/QuartzCore.h>

statusvol *svol;
UIInterfaceOrientation orient;
UIColor *statusStyle;

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
			
			CGFloat white;
			[statusStyle getWhite:&white alpha:nil];
			
			UIImage *volImage;
			if (white>0.5){
				volImage=[svol imageForState:currentStep withMode:@"light"];
			}else{
				volImage=[svol imageForState:currentStep withMode:@"dark"];
			}
			
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
			
			// Load our preferences
			[self loadPrefs];
		}
		
		return self;
	}
	
	// Did receive white color
	- (void)didReceiveNotification:(NSNotification *)notification{
		statusStyle=[notification object];
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
	
	- (BOOL)timeTeardownEnabled{
		return ([[self prefs] objectForKey:@"statusvol.timeEnabled"]==nil || [[[self prefs] objectForKey:@"statusvol.timeEnabled"] intValue]==YES);
	}
	
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
	
	- (void)didUpdateColor:(UIColor *)color{
		statusStyle=color;
	}
	
@end

static void PreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[svol loadPrefs];
}

// Only way to reliably get these messages...
static void GotWhite(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[svol didUpdateColor:[UIColor whiteColor]];
}

static void GotBlack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[svol didUpdateColor:[UIColor blackColor]];
}

// Set things up	
__attribute__((constructor)) static void init() {
	svol=[[statusvol alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:svol selector:@selector(didReceiveNotification:) name:@"statusvol_NNC" object:nil];
	
	// Handle preference changes
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChanged, CFSTR("com.chewmieser.statusvol.prefs-changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	
	// Handle color events
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, GotWhite, CFSTR("com.chewmieser.statusvol.gotWhite"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, GotBlack, CFSTR("com.chewmieser.statusvol.gotBlack"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}