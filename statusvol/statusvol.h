#import <objc/runtime.h>
#import <substrate.h>
#import <QuartzCore/QuartzCore.h>

@interface statusvol : NSObject
	- (void)didReceiveNotification:(NSNotification *)notification;
@end

// Time cloaking functionality
@interface SBMainStatusBarStateProvider
	+ (id)sharedInstance;
	- (void)enableTime:(_Bool)arg1 crossfade:(_Bool)arg2 crossfadeDuration:(double)arg3;
@end

// Method injection
@interface SBHUDController
	- (id)modifyHUD:(id)view;
	- (CGRect)calculateFrame:(CGRect)baseFrame;
@end
	
@interface SBHUDView : UIView
@end