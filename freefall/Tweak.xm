#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

SystemSoundID soundID;
CMMotionManager *manager;
bool playing;

%hook SpringBoard
	
	// Setup FreeFall
	-(void)applicationDidFinishLaunching:(id)application{
		%orig;
		
		// Setup sound
		NSBundle *bundle=[[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/FreeFallBundle.bundle"] autorelease];
		NSString *soundPath=[bundle pathForResource:@"WilhelmScream" ofType:@"wav"];
		AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: soundPath],&soundID);
		
		// Setup CoreMotion
		manager=[[CMMotionManager alloc] init];
		manager.accelerometerUpdateInterval=0.01;
		[manager startAccelerometerUpdates];
		
		playing=NO;
		
		// Setup timer
		[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateAccelData:) userInfo:nil repeats:YES];
	}
	
	%new(v:@)
	-(void)updateAccelData:(NSTimer *)timer{
		double accel=sqrt(pow(manager.accelerometerData.acceleration.x,2) + pow(manager.accelerometerData.acceleration.y,2) + pow(manager.accelerometerData.acceleration.z,2));
		
		if (accel<0.04 && !playing){ // Original was 8.0
			playing=YES;
			[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(doStopPlay:) userInfo:nil repeats:YES];
			AudioServicesPlaySystemSound(soundID);
		}
	}
	
	%new(v:@)
	-(void)doStopPlay:(NSTimer *)timer{
		playing=NO;
	}
	
%end