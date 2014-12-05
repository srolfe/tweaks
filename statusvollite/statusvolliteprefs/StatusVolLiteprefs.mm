//#import <Preferences/Preferences.h>

#import "prefs-common.h"

@interface StatusVolLiteprefsListController: PSListController {
}
@end

@implementation StatusVolLiteprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"StatusVolLiteprefs" target:self] retain];
	}
	
	return _specifiers;
}

/*- (UITableViewCell *)tableView:(id)tableView cellForRowAtIndexPath:(id)indexPath{
	UITableViewCell *tmp=[super tableView:tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"!--- tmp: %@",tmp);
	[tmp setTintColor:[UIColor redColor]];
	return tmp;
}*/
@end

// vim:ft=objc
