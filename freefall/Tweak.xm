#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

SystemSoundID soundID;
CMMotionManager *manager;
bool playing;
NSTimer *timed;
bool shouldPlay;

#define PREFS_PLIST_PATH	@"/private/var/mobile/Library/Preferences/com.chewmieser.freefall.plist"
#define DebugLog(s, ...) NSLog(@"[FreeFall] %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
static NSString *enabled = nil;
static NSString *screamSound = nil;

//
// Load user preferences.
//
static void loadPreferences() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PLIST_PATH];
	
	if (prefs && prefs[@"enabled"]) {
        DebugLog(@"preferences found. Setting enabled");
		enabled = prefs[@"enabled"];
	} else {
        //	 use default setting
        DebugLog(@"using default value for enabled");
        enabled = @"default";
    }
    
    if (prefs && prefs[@"screamSound"]) {
        DebugLog(@"preferences found. Setting sceamSound");
		screamSound = prefs[@"screamSound"];
        // Setup sound
        NSBundle *bundle=[[[NSBundle alloc] initWithPath:@"/Library/Application Support/FreeFallBundle.bundle"] autorelease];
        NSString *soundPath=[bundle pathForResource:screamSound ofType:@"wav"];
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: soundPath   ],&soundID);
	} else {
        //	 use default setting
        DebugLog(@"using default value for screamSound");
        // Setup sound
        NSBundle *bundle=[[[NSBundle alloc] initWithPath:@"/Library/Application Support/FreeFallBundle.bundle"] autorelease];
        NSString *soundPath=[bundle pathForResource:@"WilhelmScream" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: soundPath   ],&soundID);
    }
}

//
// Handle notifications from Settings.
//
static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name,
						 const void *object, CFDictionaryRef userInfo) {
    
	DebugLog(@"******** Settings Changed Notification ********");
    loadPreferences();
}

static void prefsChangedSound(CFNotificationCenterRef center, void *observer, CFStringRef name,
						 const void *object, CFDictionaryRef userInfo) {
    
	DebugLog(@"******** Settings Changed Notification ********");
    loadPreferences();
    shouldPlay=YES;
}

%hook SpringBoard

	// Setup FreeFall
	-(void)applicationDidFinishLaunching:(id)application{
		%orig;
        
		if (enabled){
            
            // Setup CoreMotion
            manager=[[CMMotionManager alloc] init];
            manager.accelerometerUpdateInterval=0.01;
            [manager startAccelerometerUpdates];
		
            // Small control variable
            playing=NO;
		
            // Setup timer
            if (!timed){
                timed=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector: @selector(updateAccelData:) userInfo:nil repeats:YES];
            }
        }
    }
	
	%new(v:@)
	-(void)updateAccelData:(NSTimer *)timer{
        if (enabled) {
            double accel=sqrt(pow(manager.accelerometerData.acceleration.x,2) + pow(manager.accelerometerData.acceleration.y,2) + pow(manager.accelerometerData.acceleration.z,2));
            
            if (accel<0.04) { // Original was 8.0
                shouldPlay=YES;
                [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(doStopPlay:) userInfo:nil repeats:NO];
            }
            
            if (shouldPlay == YES && !playing){
                playing=YES;
                [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(doStopPlay:) userInfo:nil repeats:NO];
                AudioServicesPlaySystemSound(soundID);
            }
        }
    }
	
	%new(v:@)
	-(void)doStopPlay:(NSTimer *)timer{
        playing=NO;
        shouldPlay=NO;
	}

%end

// Initialization stuff
%ctor {
	@autoreleasepool {
	    NSLog(@"FreeFall loaded.");
		loadPreferences();
		
		//start listening for notifications from Settings
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)prefsChanged,
										CFSTR("com.chewmieser.freefall/prefsChanged"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately
                                        );
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)prefsChangedSound,
										CFSTR("com.chewmieser.freefall/prefsChanged-sound"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately
                                        );
		
		%init;
	}
}
