#import "statusvol.h"

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
	- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2{ if ([svol isEnabled]){%orig([self modifyHUD:arg1], arg2);}else{%orig;} }
	- (void)presentHUDView:(id)arg1{ if ([svol isEnabled]){%orig([self modifyHUD:arg1]);}else{%orig;} }
	
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
		if ([svol isEnabled]){
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
				// Remove backdrop, if available
				if ([NSStringFromClass([t class]) isEqualToString:@"_UIBackdropView"]){
					[t removeFromSuperview];
				}
			}
		
			// Reset frame
			tmp.frame=[self calculateFrame:tmp.frame];
		
			// Hide time
			[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:NO crossfade:NO crossfadeDuration:0];
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
		if ([svol isEnabled]){
			for (UIView *tmp in arg1.subviews){
				// Fix the frame, giving the indicator icons more space
				tmp.frame=CGRectMake(tmp.frame.origin.x,tmp.frame.origin.y,5.5,5.5);
				
				// Mask
				if ([svol isMasked]){
					CALayer *mask=[[CALayer alloc] init];
					mask.frame=tmp.layer.bounds;
					
					if (CGColorGetAlpha(tmp.layer.backgroundColor)<1.0){
						[mask setContents:[svol maskedOffImage]];
					}else{
						[mask setContents:[svol maskedImage]];
					}
					
					[tmp.layer setMask:mask];
				}
				
				// Show hidden indicators
				if (CGColorGetAlpha(tmp.layer.backgroundColor)<1.0){
					[tmp.layer setBackgroundColor:CGColorCreateCopyWithAlpha(tmp.layer.backgroundColor,[svol offTransparency])];
				}
			}
		}
		
		%orig(arg1,arg2,arg3,arg4);
	}
	
%end

@implementation statusvol
	@synthesize prefs;
	
	- (id)init{
		if (self=[super init]){
			[self loadPrefs];
		}
		
		return self;
	}
	
	- (void)didReceiveNotification:(NSNotification *)notification{
		statusStyle=[notification object];
	}
	
	- (void)loadPrefs{
		prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.chewmieser.statusvol.plist"];
		_MI=nil;
		_MOI=nil;
	}
	
	- (float)offTransparency{
		if (![[self prefs] objectForKey:@"statusvol.offTrans"]){
			return 0.25;
		}else{
			return [(NSNumber *)[[self prefs] objectForKey:@"statusvol.offTrans"] floatValue];
		}
	}
	
	- (BOOL)isEnabled{
		return ([[self prefs] objectForKey:@"statusvol.enabled"]==nil || [[[self prefs] objectForKey:@"statusvol.enabled"] intValue]==YES);
	}
	
	- (BOOL)isMasked{
		// No mask key OR mask key == none
		if ([[self prefs] objectForKey:@"statusvol.mask"] && ![[[self prefs] objectForKey:@"statusvol.mask"] isEqualToString:@"none"]){
			return YES;
		}else{
			return NO;
		}
	}
	
	// On mask
	- (id)maskedImage{
		if (_MI==nil){
			_MI=(id)[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Documents/StatusVol/%@/on.png",[[self prefs] objectForKey:@"statusvol.mask"]]].CGImage;
		}
		
		return _MI;
	}
	
	// Off mask
	- (id)maskedOffImage{
		if (_MOI==nil){
			_MOI=(id)[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Documents/StatusVol/%@/off.png",[[self prefs] objectForKey:@"statusvol.mask"]]].CGImage;
		}
		
		return _MOI;
	}
	
@end

static void PreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[svol loadPrefs];
}
	
__attribute__((constructor)) static void init() {
	svol=[[statusvol alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:svol selector:@selector(didReceiveNotification:) name:@"statusvol_NNC" object:nil];
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChanged, CFSTR("com.chewmieser.statusvol.prefs-changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}