//#import <Preferences/Preferences.h>
//enum PSListItemCell;

enum cType{
	PSGroupCell,
	PSLinkCell,
	PSLinkListCell,
	PSListItemCell,
	PSTitleValueCell,
	PSSliderCell,
	PSSwitchCell,
	PSStaticTextCell,
	PSEditTextCell,
	PSSegmentCell,
	PSGiantIconCell,
	PSGiantCell,
	PSSecureEditTextCell,
	PSButtonCell,
	PSEditTextViewCell,
	PSSpinnerCell
};

#define NSTrue ((__bridge id) kCFBooleanTrue)
#define NSFalse ((__bridge id) kCFBooleanFalse)

@interface PSSpecifier
	+ (id)groupSpecifierWithName:(id)arg1;
	+ (id)preferenceSpecifierNamed:(id)arg1 target:(id)arg2 set:(SEL)arg3 get:(SEL)arg4 detail:(Class)arg5 cell:(long long)arg6 edit:(Class)arg7;
	- (void)setProperty:(id)arg1 forKey:(id)arg2;
	- (void)setupIconImageWithPath:(id)arg1;
	- (id)propertyForKey:(id)arg1;
@end

@interface PSViewController{
}
- (id)readPreferenceValue:(id)arg1;
- (void)setPreferenceValue:(id)arg1 specifier:(id)arg2;
@end

@interface PSListController: PSViewController{
	id _specifiers;
}
	-(id)loadSpecifiersFromPlistName:id target:id;
	@property (nonatomic, retain) id _specifiers;
	- (long long)indexForIndexPath:(id)arg1;
	- (id)specifierAtIndex:(long long)arg1;
	- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
@end
	
@interface PSListItemsController: PSListController{
}
- (void)listItemSelected:(NSIndexPath *)arg1;
@end

@interface statusvolprefsListController: PSListItemsController {
	NSMutableDictionary *prefs;
	int selected;
}
@end

@implementation statusvolprefsListController
- (id)specifiers {
	// Load our preferences and record the selected value
	prefs=[[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.chewmieser.statusvol.plist"] ?: [[NSMutableDictionary alloc] init];
	selected=0;
	NSString *selectedId=(NSString *)[prefs objectForKey:@"statusvol.mask"];
	
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"statusvolprefs" target:self] retain];
		
		// Make it mutable
		NSMutableArray *arr=[NSMutableArray arrayWithArray:_specifiers];
		
		// Create our skin group
		PSSpecifier* groupSpecifier = [PSSpecifier groupSpecifierWithName:@"Theme"];
		[groupSpecifier setProperty:NSTrue forKey:@"isRadioGroup"];
		[groupSpecifier setProperty:@"Skins located in /Library/StatusVol" forKey:@"footerText"];
		[arr addObject:groupSpecifier];
		
		// Create default option
		/*PSSpecifier *spec=[PSSpecifier preferenceSpecifierNamed:@"Default" target:self set:nil get:nil detail:nil cell:PSListItemCell edit:nil];
		[spec setProperty:@"none" forKey:@"value"];
		[arr addObject:spec];*/
		
		// Find skins
		NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/StatusVol" error:NULL];
		
		int i=0;
		for (NSString *tmp in directoryContent){
			// Setup skin specifier
			PSSpecifier *tmpSpec=[PSSpecifier preferenceSpecifierNamed:tmp target:self set:nil get:nil detail:nil cell:PSListItemCell edit:nil];
			[tmpSpec setProperty:tmp forKey:@"value"];
			[tmpSpec setProperty:[NSNumber numberWithInteger:3] forKey:@"alignment"];
			
			// If selected, record it
			if ([tmp isEqualToString:selectedId]) selected=i;
			
			// Load skin images
			/*UIImage *on=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Documents/StatusVol/%@/on.png",tmp]];
			UIImage *off=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Documents/StatusVol/%@/off.png",tmp]];
			
			// Combine skin images
			CGSize iconSize=CGSizeMake(on.size.width*2,on.size.height*2);
			UIGraphicsBeginImageContext(iconSize);
			[on drawInRect:CGRectMake(0,0,on.size.width,on.size.height)];
			[off drawInRect:CGRectMake(on.size.width,on.size.height,off.size.width,off.size.height)];
			UIImage *iconImage=UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();*/
			
			// Show skin in icon
			[tmpSpec setProperty:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/StatusVol/%@/dark/8.png",tmp]] forKey:@"iconImage"];
			
			// Add specifier to array
			[arr addObject:tmpSpec];
			
			i++;
		}
		
		if (i==0){
			PSSpecifier *noSkins=[PSSpecifier preferenceSpecifierNamed:@"No skins found :(" target:self set:nil get:nil detail:nil cell:PSTitleValueCell edit:nil];
			[arr addObject:noSkins];
		}
		
		_specifiers=[arr copy];
	}
	
	return _specifiers;
}

// Select skin
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
  if (section == ([tableView numberOfSections] - 1)){
	  [super listItemSelected:[NSIndexPath indexPathForRow:selected inSection:1]];
  }
  
  return [super tableView:tableView viewForFooterInSection:section];
}

// Set and save our skin choice
- (void)listItemSelected:(NSIndexPath *)arg1{
	// If we're selecting a skin
	if (arg1.section!=0){
		// Select it
		[super listItemSelected:arg1];
		
		// Load the specifier and record the value
		PSSpecifier *tmp=[self specifierAtIndex:[self indexForIndexPath:arg1]];
		prefs=[[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.chewmieser.statusvol.plist"] ?: [[NSMutableDictionary alloc] init];
		[prefs setObject:[tmp propertyForKey:@"value"] forKey:@"statusvol.mask"];
		
		// Save it to defaults
		NSData *data = [NSPropertyListSerialization dataWithPropertyList:prefs format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
		//NSData *data = [NSPropertyListSerialization dataFromPropertyList:prefs format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
		[data writeToFile:@"/var/mobile/Library/Preferences/com.chewmieser.statusvol.plist" atomically:YES];
		
		// Notify
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chewmieser.statusvol.prefs-changed"), NULL, NULL, NO);
	}
	
}
@end

// vim:ft=objc
