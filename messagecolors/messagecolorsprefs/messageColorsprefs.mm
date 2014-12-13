@interface PSListController{
	NSArray *_specifiers;
}
	- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2;
@end

@interface messageColorsprefsListController: PSListController {
}
@end

@implementation messageColorsprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"messageColorsprefs" target:self];
	}
	return _specifiers;
}
@end

// vim:ft=objc
