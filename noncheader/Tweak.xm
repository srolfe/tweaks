// Bare-bones interface for UIView inheritance
@interface SBNotificationCenterHeaderView : UIView
@end

%hook SBNotificationCenterHeaderView
	
	// Manipulation after the _clearButton should have been set
	- (void)layoutSubviews{
		%orig;
		
		// Record frames
		CGRect newFrame=self.frame;
		CGRect newBounds=self.bounds;
		
		// _clearButton seems to be an easy reference to determine which page we're on
		// Also noticed a "hasClear" variable, but that doesn't seem used
		
		// Refuse manipulation if we're not on the today page
		if (MSHookIvar<id>(self,"_clearButton")==nil){
			newFrame.size.height=0;
			newBounds.size.height=0;
			
			// Set new sizes and hide the view
			[self setFrame:newFrame];
			[self setBounds:newBounds];
			[self setHidden:YES];
		}
	}
	
%end