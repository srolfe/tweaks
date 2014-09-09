#import <objc/runtime.h>
#import <substrate.h>

@interface UIStatusBarForegroundStyleAttributes
	- (id)tintColor;
@end

@interface UIStatusBarForegroundView
	@property(readonly, nonatomic) UIStatusBarForegroundStyleAttributes *foregroundStyle;
@end

@interface UIStatusBar{
	UIStatusBarForegroundView *_foregroundView;
}
	- (_Bool)isHidden;
	- (long long)currentStyle;
	- (id)activeTintColor;
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