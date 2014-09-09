#import "statusvolKit.h"

%hook UIApplication
	- (void)applicationDidFinishLaunching:(id)arg1{
		%orig;
		[self applicationState];
	}
	
	- (void)_reportAppLaunchFinished{
		%orig;
		[self applicationState];
	}
	
	- (void)applicationWillEnterForeground:(id)arg1{
		%orig;
		[self applicationState];
	}
	
	- (void)_sendWillEnterForegroundCallbacks{
		%orig;
		[self applicationState];
	}
	
	- (long long)applicationState{
		UIApplicationState state=%orig;
		if (state == UIApplicationStateActive){
			// If there's a HUD, ignore this event
			NSArray *windows=self.windows;
			
			BOOL flag=NO;
			for (UIWindow *win in windows){
				if ([win isKindOfClass:[objc_getClass("SBHUDWindow") class]]){
					flag=YES;
				}
			}
			
			if (flag==NO){
				// Get style
				long style=(long)[self statusBarStyle];
			
				// Push out notification
				if (style!=0 && style!=300){
					CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chewmieser.statusvol.gotWhite"), NULL, NULL, false);
				}else{
					CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chewmieser.statusvol.gotBlack"), NULL, NULL, false);
				}
			}
		}
		return state;
	}
%end