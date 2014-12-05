#import "prefs-common.h"

@interface legacyListController : PSListController {}
@end

@implementation legacyListController
	- (id)specifiers {
		if(_specifiers == nil) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"legacyPrefs" target:self] retain];
		}
		return _specifiers;
	}
@end