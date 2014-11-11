#import "statusvolKit.h"
#import "rocketbootstrap.h"

@interface CPDistributedMessagingCenter : NSObject
	+(id)centerNamed:(id)arg1;
	-(void)runServerOnCurrentThread;
	-(void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
	-(void)sendMessageName:(id)arg1 userInfo:(id)arg2;
@end
	
/*%hook UIStatusBarForegroundView
	- (UIStatusBarForegroundStyleAttributes *)foregroundStyle{
		UIStatusBarForegroundStyleAttributes *tmp=%orig;
		
		// Get color & bundle
		UIColor *tintColor=[tmp tintColor];
		CGFloat white, alpha;
		[tintColor getWhite:&white alpha:&alpha];
		//[tintColor release];
		
		//NSDictionary *userInfo=;
		
		// Push notification
		//CPDistributedMessagingCenter *c = [%c(CPDistributedMessagingCenter) centerNamed:@"com.chewmieser.statusvol"];
		//rocketbootstrap_distributedmessagingcenter_apply(c);
		//[c sendMessageName:@"colorChange" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle mainBundle] bundleIdentifier],@"bundle",[NSString stringWithFormat:@"%f",white],@"color",nil]];
		//[c release];
		
		return tmp;
	}
%end
	*/