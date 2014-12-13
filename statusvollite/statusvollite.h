@interface UIView (ColorOfPoint)
- (UIColor *) colorOfPoint:(CGPoint)point;
@end

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

@interface UIScreen (svolPrivate)
	- (id)snapshot;
	- (id)snapshotView;
	- (id)snapshotViewAfterScreenUpdates:(BOOL)arg1;
	
	- (void)_enumerateWindowsWithBlock:( void ( ^ )( id ) )arg1;
	- (id)_snapshotExcludingWindows:(id)arg1 withRect:(struct CGRect)arg2;
@end

@interface SpringBoard : UIApplication
	- (id)_accessibilityFrontMostApplication;
	- (id)_keyWindowForScreen:(id)arg1;
@end

@interface _UIReplicantView : UIView
@end

// THIS
@interface SBApplication
	- (id)mainSceneID;
	- (id)mainScene;
	
	- (id)transitionContext;
	- (id)executionContext;
	
	- (id)_screenFromSceneID:(id)arg1;
	
	- (id)_defaultPNGNameFromSuspensionSettings;
	
	- (id)_defaultPNGForSceneID:(id)arg1 size:(struct CGSize)arg2 scale:(double)arg3 launchingOrientation:(long long)arg4 orientation:(long long *)arg5;
	
	- (id)_snapshotImageWithImageName:(id)arg1 sceneID:(id)arg2 size:(struct CGSize)arg3 scale:(double)arg4 downscaled:(_Bool)arg5 launchingOrientation:(long long)arg6 originalOrientation:(long long *)arg7 currentOrientation:(long long *)arg8;
	- (id)_snapshotImageInfoForSceneID:(id)arg1 named:(id)arg2 size:(struct CGSize)arg3 scale:(double)arg4 downscaled:(_Bool)arg5 launchingOrientation:(long long)arg6;
	- (id)_snapshotImageInfoForSceneID:(id)arg1 size:(struct CGSize)arg2 scale:(double)arg3 downscaled:(_Bool)arg4 launchingOrientation:(long long)arg5;
	- (id)_snapshotImageForSnapshotImageInfo:(id)arg1 downscaled:(_Bool)arg2 originalOrientation:(out long long *)arg3 currentOrientation:(out long long *)arg4;
	
	- (void)_saveSnapshotForSceneID:(id)arg1 frame:(struct CGRect)arg2 name:(id)arg3 overrideScale:(double)arg4;
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
	
@interface StatusVol : NSObject{
	UILabel *indicatorLabel;
	UIVisualEffectView *blurView;
	UIViewController *primaryVC;
	_UIBackdropView *back;
	NSTimer *hideTimer;
	svolWindow *sVolWindow;
	NSDictionary *preferences;
	bool isAnimatingClose;
	bool svolCloseInterrupt;
}
	- (id)init;
	- (void)initializeWindow;
	- (void)_updateSvolLabel:(int)level type:(int)type;
	- (void)hideSvolWindow;
@end