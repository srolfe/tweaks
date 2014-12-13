#import "prefs-common.h"

@interface animationListController : PSListController {}
@end

@implementation animationListController
	- (id)specifiers {
		if(_specifiers == nil) {
			_specifiers = [self loadSpecifiersFromPlistName:@"animatePrefs" target:self];// retain];
		}
		return _specifiers;
	}
@end