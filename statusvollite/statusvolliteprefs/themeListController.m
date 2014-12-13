#import "prefs-common.h"

@interface themeListController : PSListController {}
@end

@implementation themeListController
	- (id)specifiers {
		if(_specifiers == nil) {
			_specifiers = [self loadSpecifiersFromPlistName:@"themePrefs" target:self];// retain];
		}
		return _specifiers;
	}
@end