#import "statusvolKit.h"
#import <objcipc/objcipc.h>

%hook UIStatusBarForegroundView
	- (UIStatusBarForegroundStyleAttributes *)foregroundStyle{
		UIStatusBarForegroundStyleAttributes *tmp=%orig;
		
		// Get color & bundle
		UIColor *tintColor=[tmp tintColor];
		//CGFloat white, alpha;
		//[tintColor getWhite:&white alpha:&alpha];
		if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]){
			[OBJCIPC sendMessageToSpringBoardWithMessageName:@"statusVol.didGetColor" dictionary:@{ @"bundle": [[NSBundle mainBundle] bundleIdentifier], @"color" : tintColor } replyHandler:^(NSDictionary *response) {
			}];
		}
		
		return tmp;
	}
	
	- (void)stopIgnoringData:(BOOL)arg1{
		[self foregroundStyle];
		%orig;
	}
	
	- (void)setStatusBarData:(id)arg1 actions:(int)arg2 animated:(BOOL)arg3{
		[self foregroundStyle];
		%orig;
	}
	
%end