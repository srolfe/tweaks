// Bare-bones PSListController header... It compiles, shut up!
@interface PSListController: UIViewController{
	NSArray *_specifiers;
}

	@property (nonatomic, retain) id _specifiers;
	- (id)loadSpecifiersFromPlistName:id target:id;
	- (void)setPreferenceValue:(id)arg1 specifier:(id)arg2;
@end

@interface FreeFallPrefsListController: PSListController {
	NSMutableDictionary *prefs;
	NSArray *directoryContent;
	SystemSoundID selectedSound;
}

	- (NSArray *)getValues:(id)target;
	- (void)previewAndSet:(id)value forSpecifier:(id)specifier;
@end