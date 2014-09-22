#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FreeFall.h"

// Reference to our FreeFall object
FreeFall *freeFallController;
	
@implementation FreeFall
	@synthesize prefs;
	
	- (id)init{
		if (self=[super init]){
			// Load our preferences
			[self loadPrefs];
		}
		
		return self;
	}
	
	// Did receive preference reload notification
	- (void)loadPrefs{
		if (prefs) [[self prefs] release];
		if (timed) [timed invalidate];
		if (manager) [manager stopAccelerometerUpdates];
		
		AudioServicesDisposeSystemSoundID(fallingSound);
		AudioServicesDisposeSystemSoundID(stoppingSound);
		
		prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.chewmieser.freefall.plist"];
		
		// Setup falling sound
		NSString *fallPref=[[self prefs] objectForKey:@"fallingSound"];
		if (fallPref==nil) fallPref=@"WilhelmScream.wav";
		
		if (![fallPref isEqualToString:@"None"]){
			AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[NSString stringWithFormat:@"/Library/FreeFall/%@",fallPref]],&fallingSound);
		}
		
		// Setup stopping sound
		NSString *stopPref=[[self prefs] objectForKey:@"stoppingSound"];
		if (stopPref==nil) stopPref=@"None";
		
		if (![stopPref isEqualToString:@"None"]){
			AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[NSString stringWithFormat:@"/Library/FreeFall/%@",stopPref]],&stoppingSound);
		}
		
		// Are we completely disabled?
		if (fallingSound!=0 || stoppingSound!=0){
			// Control variables
			fallSoundPlaying=NO;
			stopSoundPlaying=NO;
			
			// Setup CoreMotion
			manager=[[CMMotionManager alloc] init];
			manager.accelerometerUpdateInterval=0.01;
			[manager startAccelerometerUpdates];
			
			// Start the timer after a delay (was causing issues with the Preference Pane)
			[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(enableTimer:) userInfo:nil repeats:NO];
		}
	}
	
	- (void)updateAccelData:(NSTimer *)timer{
		double accel=sqrt(pow(manager.accelerometerData.acceleration.x,2) + pow(manager.accelerometerData.acceleration.y,2) + pow(manager.accelerometerData.acceleration.z,2));
		
		if (accel<0.04 && !fallSoundPlaying){ // Original was 8.0
			fallSoundPlaying=YES;
			[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(doStopFallPlay:) userInfo:nil repeats:NO];
			AudioServicesPlaySystemSound(fallingSound);
		}
		
		if (accel>6.0 && !stopSoundPlaying){ // Original was 8.0
			stopSoundPlaying=YES;
			[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(doStopStopPlay:) userInfo:nil repeats:NO];
			AudioServicesPlaySystemSound(stoppingSound);
		}
	}
	
	- (void)doStopFallPlay:(NSTimer *)timer{
		fallSoundPlaying=NO;
	}
	
	- (void)doStopStopPlay:(NSTimer *)timer{
		stopSoundPlaying=NO;
	}
	
	- (void)enableTimer:(NSTimer *)timer{
		timed=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateAccelData:) userInfo:nil repeats:YES];
	}
	
@end
	
	
	
static void PreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	[freeFallController loadPrefs];
}

// Set things up	
__attribute__((constructor)) static void init() {
	freeFallController=[[FreeFall alloc] init];
	
	// Handle preference changes
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChanged, CFSTR("com.chewmieser.freefall.prefs-changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}