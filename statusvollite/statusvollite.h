@interface UIVisualEffectView (ex)
	- (void)_setEffect:(id)arg1;
@end

@interface VolumeControl : NSObject
	+ (id)sharedVolumeControl;
	- (float)getMediaVolume;
	- (float)volume;
	- (void)_initializeEUVolumeLimits;
	- (void)sendEUVolumeLimitAcknowledgementIfNecessary;
@end

@interface SpringBoard : UIApplication
@end

@interface SpringBoard (svol)
	- (void)_updateSvolLabel:(int)level type:(int)type;
@end
	
@interface UIWindow (ex)
	- (void)_setSecure:(BOOL)arg1;
	- (void)_finishedFullRotation:(id)arg1 finished:(id)arg2 context:(id)arg3;
	- (void)_updateToInterfaceOrientation:(int)arg1 animated:(BOOL)arg2;
	- (void)setHidden:(BOOL)arg1;
@end

@interface svolWindow : UIWindow
	- (void)fixSvolWindow;
@end
	
@interface _UIBackdropView : UIView
	- (id)initWithFrame:(struct CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3;
	-(void)setAutosizesToFitSuperview:(BOOL)arg1;
	-(void)setStyle:(int)arg1;
@end
	
@interface SBMainStatusBarStateProvider
	+(id)sharedInstance;
	-(void)enableTime:(BOOL)arg1 crossfade:(BOOL)arg2 crossfadeDuration:(int)arg3;
@end
	
@interface _UILegibilityLabel : UIView
	- (id)initWithSettings:(id)arg1 strength:(float)arg2 string:(id)arg3 font:(id)arg4 options:(int)arg5;
	- (id)initWithSettings:(id)arg1 strength:(float)arg2 string:(id)arg3 font:(id)arg4;
	- (void)updateImage;
	- (BOOL)usesSecondaryColor;
	- (id)imageView;
	- (id)shadowImageView;
	- (void)updateForChangedSettings:(id)arg1;
	- (id)drawingColor;
@end
	
@interface _UILegibilitySettings : NSObject
	- (id)initWithContentColor:(id)arg1 contrast:(float)arg2;
	
	- (id)initWithStyle:(int)arg1 primaryColor:(id)arg2 secondaryColor:(id)arg3 shadowColor:(id)arg4;
	+ (id)sharedInstanceForStyle:(int)arg1;
	- (void)setSecondaryColor:(id)arg1;
	- (void)setPrimaryColor:(id)arg1;
@end