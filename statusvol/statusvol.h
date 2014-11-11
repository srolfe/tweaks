#import <objc/runtime.h>
#import <substrate.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (additions)
- (void)_removeAllAnimations:(BOOL)arg1;
@end

// StatusVol Object
@interface statusvol : NSObject
	- (UIImage *)imageForState:(int)state withMode:(NSString *)mode;
	- (void)loadPrefs;
	- (BOOL)timeTeardownEnabled;
	- (BOOL)isEnabled;
	- (void)didUpdateColor:(UIColor *)color;
	
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

	typedef struct {
	    _Bool itemIsEnabled[25];
	    char timeString[64];
	    int gsmSignalStrengthRaw;
	    int gsmSignalStrengthBars;
	    char serviceString[100];
	    char serviceCrossfadeString[100];
	    char serviceImages[2][100];
	    char operatorDirectory[1024];
	    unsigned int serviceContentType;
	    int wifiSignalStrengthRaw;
	    int wifiSignalStrengthBars;
	    unsigned int dataNetworkType;
	    int batteryCapacity;
	    unsigned int batteryState;
	    char batteryDetailString[150];
	    int bluetoothBatteryCapacity;
	    int thermalColor;
	    unsigned int thermalSunlightMode:1;
	    unsigned int slowActivity:1;
	    unsigned int syncActivity:1;
	    char activityDisplayId[256];
	    unsigned int bluetoothConnected:1;
	    unsigned int displayRawGSMSignal:1;
	    unsigned int displayRawWifiSignal:1;
	    unsigned int locationIconType:1;
	    unsigned int quietModeInactive:1;
	    unsigned int tetheringConnectionCount;
	} CDStruct_0e61b686;

@interface UIStatusBarServer
	+ (int)getStyleOverrides;
	//+ (CDStruct_9dad2be2 *)getStatusBarOverrideData;
	+ (const CDStruct_0e61b686 *)getStatusBarData;
	@property(retain, nonatomic) id statusBar;
@end
	
	@interface SBWindowManager
	- (id)dumpKnownWindows;
	- (id)dumpHidingState;
	@end
	
@interface UIWindow (priv)
	+ (UIWindow *)_statusBarControllingWindow;
+ (id)allWindowsIncludingInternalWindows:(_Bool)arg1 onlyVisibleWindows:(_Bool)arg2;
+ (id)_externalKeyWindow;
@end
	
