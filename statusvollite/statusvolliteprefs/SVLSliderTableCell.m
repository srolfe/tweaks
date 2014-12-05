#import "prefs-common.h"

@interface SVLSliderTableCell : PSSliderTableCell //our class
@end
 
@implementation SVLSliderTableCell
 
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 { //init method
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3]; //call the super init method
	if (self) {
		[((UISlider *)[self control]) setMinimumTrackTintColor:[UIColor redColor]]; //change the switch color
	}
	return self;
}
 
@end