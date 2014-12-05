#import "prefs-common.h"

@interface SVLSwitchTableCell : PSSwitchTableCell //our class
@end
 
@implementation SVLSwitchTableCell
 
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 { //init method
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3]; //call the super init method
	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:[UIColor redColor]]; //change the switch color
	}
	return self;
}
 
@end