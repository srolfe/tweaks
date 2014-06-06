//#import <Preferences/Preferences.h>
@interface PSListController{
	id _specifiers;
}
	-(id)loadSpecifiersFromPlistName:id target:id;
	@property (nonatomic, retain) id _specifiers;
@end

@interface statusvolprefsListController: PSListController {
}
@end

@implementation statusvolprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"statusvolprefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
