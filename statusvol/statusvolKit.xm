#import "statusvolKit.h"
	
%hook UIStatusBar
	- (void)didMoveToSuperview{
		if (![self isHidden]){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"statusvol_NNC" object:[[MSHookIvar<UIStatusBarForegroundView *>(self,"_foregroundView") foregroundStyle] tintColor]];
		}
		
		%orig;
	}
	
	- (void)_willEnterForeground:(id)arg1{
		if (![self isHidden]){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"statusvol_NNC" object:[[MSHookIvar<UIStatusBarForegroundView *>(self,"_foregroundView") foregroundStyle] tintColor]];
		}
		
		%orig;
	}
%end
	
%hook UIStatusBarServer
	- (id)initWithStatusBar:(id)arg1{
		%log;return %orig;
	}
%end