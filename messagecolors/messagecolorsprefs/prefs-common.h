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

@interface PSListController : UITableViewController{
	UITableView *_table;
	id _specifiers;
}
	- (id)specifiers;
	- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2;
@end
	
	@interface PSEditableListController : PSListController
	- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
	- (BOOL)performDeletionActionForSpecifier:(id)arg1;
	- (void)setEditable:(BOOL)arg1;
	- (void)_setEditable:(BOOL)arg1 animated:(BOOL)arg2;
	@end
	
@interface PSSpecifier : NSObject
	@property(retain, nonatomic) NSString *name;
	+ (id)groupSpecifierWithName:(id)arg1;
	+ (id)preferenceSpecifierNamed:(id)arg1 target:(id)arg2 set:(SEL)arg3 get:(SEL)arg4 detail:(Class)arg5 cell:(long long)arg6 edit:(Class)arg7;
	- (void)setProperty:(id)arg1 forKey:(id)arg2;
	- (void)setupIconImageWithPath:(id)arg1;
	- (id)propertyForKey:(id)arg1;
@end

@interface PSTableCell : UITableViewCell
	-(id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
@end
	
@interface PSControlTableCell : PSTableCell
	-(UIControl *)control;
@end
	
@interface PSSwitchTableCell : PSControlTableCell
	-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
@end
	
@interface PSSliderTableCell : PSControlTableCell
	-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
@end