@interface PSListController : UITableViewController{
	UITableView *_table;
	id _specifiers;
}
	- (id)specifiers;
	- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2;
@end
	
@interface PSSpecifier : NSObject
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