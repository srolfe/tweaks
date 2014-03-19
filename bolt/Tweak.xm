%hook UIStatusBarBatteryItemView
	- (id)contentsImage{
		return NULL;
	}
%end
	
%hook UIStatusBarBatteryPercentItemView
	- (double)extraRightPadding{
		return 10;
	}
%end