@interface FreeFall : NSObject{
	SystemSoundID fallingSound;
	SystemSoundID stoppingSound;
	CMMotionManager *manager;
	bool fallSoundPlaying;
	bool stopSoundPlaying;
	NSTimer *_freeFallExecuteTimer;
	int _ringerStateToken;
	double fallSensitivity;
	double stopSensitivity;
}
	
	@property (nonatomic,retain) NSDictionary *prefs;
	-(void)loadPrefs;
	-(void)updateAccelData:(NSTimer *)timer;
	-(void)doStopFallPlay:(NSTimer *)timer;
	-(void)doStopStopPlay:(NSTimer *)timer;
	- (void)updateState;
@end