@interface FreeFall : NSObject{
	SystemSoundID fallingSound;
	SystemSoundID stoppingSound;
	CMMotionManager *manager;
	bool fallSoundPlaying;
	bool stopSoundPlaying;
	NSTimer *timed;
}
	
	@property (nonatomic,retain) NSDictionary *prefs;
	-(void)loadPrefs;
	-(void)updateAccelData:(NSTimer *)timer;
	-(void)doStopFallPlay:(NSTimer *)timer;
	-(void)doStopStopPlay:(NSTimer *)timer;
@end