#import <objc/runtime.h>
#import <substrate.h>
#import <QuartzCore/QuartzCore.h>

@interface statusvol : NSObject{
	//id _MI;
	//id _MOI;
	
	// Image storage...
	// Light: 0..16
	// Dark: 0..16
}
	//- (float)offTransparency;
	//- (id)maskedImage;
	//- (id)maskedOffImage;
	- (UIImage *)imageForState:(int)state withMode:(NSString *)mode;
	- (void)didReceiveNotification:(NSNotification *)notification;
	- (void)loadPrefs;
	- (BOOL)timeTeardownEnabled;
	- (BOOL)isEnabled;
	//- (BOOL)isMasked;
	@property (nonatomic,retain) NSDictionary *prefs;
	@property (nonatomic,retain) NSDictionary *skin;
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
	@property(nonatomic) float progress; // @synthesize progress=_progress;
	@property(nonatomic) _Bool showsProgress; // @synthesize showsProgress=_showsProgress;
	@property(nonatomic) int level; // @synthesize level=_level;
@end