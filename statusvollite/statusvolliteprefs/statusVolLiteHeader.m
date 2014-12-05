#include <UIKit/UIKit.h>
#import "prefs-common.h"

@interface statusVolLiteHeader : PSTableCell {
	UILabel *_label;
}
@end
 
@implementation statusVolLiteHeader
	- (id)initWithSpecifier:(PSSpecifier *)specifier {
		self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
		if (self) {
			_label = [[UILabel alloc] initWithFrame:[self frame]];
			[_label setTranslatesAutoresizingMaskIntoConstraints:NO];
			[_label setAdjustsFontSizeToFitWidth:YES];
			[_label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48]];
			
			/*[_label setText:@"StatusVol 2"];
			[_label setTextColor:[UIColor grayColor]];*/
			
			NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:@"StatusVol 2"];
			[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, 9)];
			[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(9, 2)];
			
			[_label setAttributedText:attributedString];
			[_label setTextAlignment:NSTextAlignmentCenter];
			[_label setBackgroundColor:[UIColor clearColor]];
 
			[self addSubview:_label];
			[self setBackgroundColor:[UIColor clearColor]];
			
			// Setup constraints
			NSLayoutConstraint *leftConstraint=[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
			NSLayoutConstraint *rightConstraint=[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
			NSLayoutConstraint *bottomConstraint=[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
			NSLayoutConstraint *topConstraint=[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
			[self addConstraints:[NSArray arrayWithObjects:leftConstraint,rightConstraint,bottomConstraint,topConstraint,nil]];
			
			[_label release];
		}
		return self;
	}
 
	- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
		// Return a custom cell height.
		return 180.f;
	}
@end