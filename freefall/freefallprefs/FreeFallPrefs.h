// Bare-bones PSListController header
@interface PSListController: NSObject{
	NSArray *_specifiers;
}

	@property (nonatomic, retain) id _specifiers;
	- (id)loadSpecifiersFromPlistName:id target:id;
@end

@interface FreeFallPrefsListController: PSListController {
	NSMutableDictionary *prefs;
	NSArray *directoryContent;
}

	- (NSArray *)getValues:(id)target;
@end