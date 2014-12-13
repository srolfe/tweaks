#import "prefs-common.h"

@interface smsColorController : PSEditableListController {}
@end
 
@implementation smsColorController
	- (id)specifiers{
		if (!_specifiers){
			NSMutableArray *spec=[[NSMutableArray alloc] init];
			
			PSSpecifier *groupSpec=[PSSpecifier groupSpecifierWithName:@""];
			[groupSpec setProperty:@"Click the edit/+ button to add hex colors. Swipe or enter editing mode to delete." forKey:@"footerText"];
			[spec addObject:groupSpec];
			
			// Load custom colors
			CFPreferencesAppSynchronize(CFSTR("com.chewmieser.messageColors"));
			NSData *dat=(__bridge NSData *)CFPreferencesCopyAppValue(CFSTR("smsColorArray"),CFSTR("com.chewmieser.messageColors"));
			
			if (dat!=nil){
				// Unarchive and load
				NSArray *tmp=(NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:dat];
				
				for (NSString *colorCode in tmp){
					PSSpecifier* colorSpec = [PSSpecifier preferenceSpecifierNamed:colorCode target:self set:NULL get:NULL detail:Nil cell:PSTitleValueCell edit:Nil];
					[spec addObject:colorSpec];
				}
			}
			
			_specifiers=[spec copy];
		}
		
		if ([_specifiers count]<2){
			[self setEditable:YES];
		}
		
		return _specifiers;
	}

	- (void)setEditable:(BOOL)arg1{
		[super setEditable:arg1];
		
		// Add item
		if (arg1==YES){
			UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popColorPicker)];
			[self.navigationItem setLeftBarButtonItem:menuItem];
		}else{	
			[self.navigationItem setLeftBarButtonItem:nil];
			
			// Save prefs
			CFPreferencesSetValue(CFSTR("smsColorArray"), (__bridge CFPropertyListRef)[NSKeyedArchiver archivedDataWithRootObject:[self getColorList]], CFSTR("com.chewmieser.messageColors"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			CFPreferencesAppSynchronize(CFSTR("com.chewmieser.messageColors"));
			
			// Send notification
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chewmieser.messageColors.prefs-changed"), NULL, NULL, TRUE);
		}
	}
	
	- (NSArray *)getColorList{
		NSMutableArray *arr=[[NSMutableArray alloc] init];
		
		for (PSSpecifier *spec in _specifiers){
			if (![[spec name] isEqualToString:@""]){
				[arr addObject:[spec name]];
			}
		}
		
		return [arr copy];
	}

	- (void)popColorPicker{
		UIAlertController *setColor=[UIAlertController alertControllerWithTitle:@"Set Color" message:@"Enter a hex color code" preferredStyle:UIAlertControllerStyleAlert];
	    UIAlertAction *setButton=[UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
			UITextField *textField=setColor.textFields[0];
			[self addColor:textField.text];
		}];

		UIAlertAction *cancelButton=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
			[setColor dismissViewControllerAnimated:YES completion:nil];
		}];

		[setColor addAction:cancelButton];
		[setColor addAction:setButton];

		[setColor addTextFieldWithConfigurationHandler:^(UITextField *textField){
			textField.text=@"#";
			textField.keyboardType=UIKeyboardTypeDefault;
		}];

		[self presentViewController:setColor animated:YES completion:nil];
	}

	- (void)addColor:(NSString *)hexCode{
		NSMutableArray *spec=[_specifiers mutableCopy];
		PSSpecifier* testSpecifier = [PSSpecifier preferenceSpecifierNamed:hexCode target:self set:NULL get:NULL detail:Nil cell:PSTitleValueCell edit:Nil];
		[spec addObject:testSpecifier];
		_specifiers=[spec copy];
		
		// Save prefs
		CFPreferencesSetValue(CFSTR("smsColorArray"), (__bridge CFPropertyListRef)[NSKeyedArchiver archivedDataWithRootObject:[self getColorList]], CFSTR("com.chewmieser.messageColors"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		CFPreferencesAppSynchronize(CFSTR("com.chewmieser.messageColors"));
		
		// Send notification
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chewmieser.messageColors.prefs-changed"), NULL, NULL, TRUE);
		
		[_table reloadData];
	}
	
	- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
		[super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
		
		// Save prefs
		CFPreferencesSetValue(CFSTR("smsColorArray"), (__bridge CFPropertyListRef)[NSKeyedArchiver archivedDataWithRootObject:[self getColorList]], CFSTR("com.chewmieser.messageColors"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		CFPreferencesAppSynchronize(CFSTR("com.chewmieser.messageColors"));
		
		// Send notification
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chewmieser.messageColors.prefs-changed"), NULL, NULL, TRUE);
	}
@end