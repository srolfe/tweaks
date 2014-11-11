@interface SBNotificationCenterHeaderView : UIView
@end

%hook SBNotificationCenterHeaderView
	
	- (void)layoutSubviews{
		%orig;
		
		CGRect newFrame=self.frame;
		CGRect newBounds=self.bounds;
		
		if (MSHookIvar<id>(self,"_clearButton")==nil){
			newFrame.size.height=0;
			newBounds.size.height=0;
			[self setFrame:newFrame];
			[self setBounds:newBounds];
			[self setHidden:YES];
		}
	}
	
%end