#import "FreeFallPrefs.h"

@implementation FreeFallPrefsListController

	// Load the two PSLinkListCells
	- (id)specifiers{
		// Load directory content
		directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/FreeFall" error:NULL];
	
		if(_specifiers == nil) {
			_specifiers=[[self loadSpecifiersFromPlistName:@"FreeFallPrefs" target:self] retain];
		}
	
	
		return _specifiers;
	}

	- (NSArray *)getValues:(id)target{
		return [[NSArray arrayWithObjects:@"None",nil] arrayByAddingObjectsFromArray:directoryContent];
	}

@end

// vim:ft=objc
