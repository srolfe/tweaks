#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

SystemSoundID soundID;

%hook SpringBoard
	
	// Setup FreeFall
	- (void)applicationDidFinishLaunching:(id)application{
		%orig;
		
		// Setup sound, save for later
		NSBundle *bundle=[[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/FreeFallBundle.bundle"] autorelease];
		NSString *soundPath=[bundle pathForResource:@"falling" ofType:@"wav"];
		AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: soundPath],&soundID);
		
		CMMotionManager *mMan=[[CMMotionManager alloc] init];
		
		// Accelerometer available - start polling
		if (mMan.accelerometerAvailable){
			
			mMan.accelerometerUpdateInterval=1.0/10.0;
			
			[mMan startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *data, NSError *error){
				dispatch_async(dispatch_get_main_queue(),^{
					double accel=sqrt(pow(data.gravity.x-data.userAcceleration.x,2) + pow(data.gravity.y-data.userAcceleration.y,2) + pow(data.gravity.z-data.userAcceleration.z,2));
					
					if (accel>6.0){ // Original was 8.0
						AudioServicesPlaySystemSound(soundID);
					}
				});
			}];
		}
	}
	
%end