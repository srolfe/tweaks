#import <Preferences/Preferences.h>

@interface FreeFallSettingsListController: PSListController {
}
@end

@implementation FreeFallSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FreeFallSettings" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
