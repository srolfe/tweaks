#import <AudioToolbox/AudioToolbox.h>
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
	
	// Preview the sound before setting
	- (void)previewAndSet:(id)value forSpecifier:(id)specifier{
		// Sample sound and set
		AudioServicesDisposeSystemSoundID(selectedSound);
		AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[NSString stringWithFormat:@"/Library/FreeFall/%@",value]],&selectedSound);
		AudioServicesPlaySystemSound(selectedSound);
		
		[super setPreferenceValue:value specifier:specifier];
	}

	// List our directory content
	- (NSArray *)getValues:(id)target{
		return [[NSArray arrayWithObjects:@"None",nil] arrayByAddingObjectsFromArray:directoryContent];
	}
	
@end
