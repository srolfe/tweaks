#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

%hook SpringBoard
	
	// Setup FreeFall
	- (void)applicationDidFinishLaunching:(id)application{
		%orig;
		
		CMMotionManager *mMan=[[CMMotionManager alloc] init];
		
		// Accelerometer available - start polling
		if (mMan.accelerometerAvailable){
			[mMan startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error){
				dispatch_async(dispatch_get_main_queue(),^{
					
					double accel=sqrt(pow(data.acceleration.x,2) + pow(data.acceleration.y,2) + pow(data.acceleration.z,2));
					
					if (accel>8.0){
						NSBundle *bundle=[[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/FreeFallBundle.bundle"] autorelease];
						NSString *soundPath=[bundle pathForResource:@"falling" ofType:@"wav"];
						SystemSoundID soundID;
						AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: soundPath],&soundID);
						AudioServicesPlaySystemSound(soundID);
					}
				});
			}];
		}
	}
	
%end