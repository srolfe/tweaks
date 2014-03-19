#import <objc/runtime.h>
#import <substrate.h>

@interface UIStatusBarForegroundStyleAttributes
	- (id)uniqueIdentifier;
	- (id)homeImageName;
	- (id)tintColor;
@end

@interface UIStatusBarForegroundView
	@property(readonly, nonatomic) UIStatusBarForegroundStyleAttributes *foregroundStyle;
@end

@interface UIStatusBar{
	UIStatusBarForegroundView *_foregroundView;
}
	@property(retain, nonatomic) UIColor *foregroundColor;
	@property(nonatomic) long long legibilityStyle;
	@property(readonly, nonatomic) int styleOverrides;
	- (id)activeTintColor;
	- (_Bool)isHidden;
@end

@interface notify:NSObject{
	long long legibility;
}

	@property (nonatomic) long long legibility;
@end
	
@implementation notify
	@synthesize legibility;
@end
	
/*%hook UIStatusBarForegroundStyleAttributes
	- (long long)legibilityStyle{
		long long tmp=%orig;
		notify *t=[[notify alloc] init];
		[t setLegibility:tmp];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"statusvol_NNC" object:t];
		
		NSLog(@"---HI--- %@",[self uniqueIdentifier]);
		NSLog(@"---HI--- %@",[self tintColor]);
		NSLog(@"---HI--- %lld",tmp);
		return tmp;
		
		for (UIView* next = [self superview]; next; next = next.superview){
			UIResponder* nextResponder = [next nextResponder];
			
			if ([nextResponder isKindOfClass:[UIViewController class]]){
				NSLog(@">>> %@",(UIViewController*)nextResponder);
			}
		}
		
		return tmp;
		
		//34359738368
		
		
		9380208574465 = white
		9380208574464 = black
		
	}
	
	- (id)textFontForStyle:(long long)arg1{
		id tmp=%orig;
		return tmp;
	}
%end*/
	
%hook UIStatusBar
	- (void)didMoveToSuperview{
		if (![self isHidden]){
			//NSLog(@"------> %lld",[self legibilityStyle]);
			
			//NSLog(@"%@",);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"statusvol_NNC" object:[[MSHookIvar<UIStatusBarForegroundView *>(self,"_foregroundView") foregroundStyle] tintColor]];
			
			
			NSLog(@"----- %d",MSHookIvar<_Bool>(self,"_showsForeground"));
		}
		
		%orig;
	}
	
	- (void)_willEnterForeground:(id)arg1{
		if (![self isHidden]){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"statusvol_NNC" object:[[MSHookIvar<UIStatusBarForegroundView *>(self,"_foregroundView") foregroundStyle] tintColor]];
			
			
			NSLog(@"----- %d",MSHookIvar<_Bool>(self,"_showsForeground"));
		}
		//NSLog(@"[]------> %lld",[self legibilityStyle]);
		%orig;
	}
%end
	
%hook UIStatusBarServer
	- (id)initWithStatusBar:(id)arg1{
		%log;return %orig;
	}
%end

	
/*%hook UIStatusBar
	
	- (id)get_legibilityStyle{
		return %orig;
	}
	
	- (void)setHidden:(_Bool)arg1{
		if (!arg1){
			NSLog(@"----> We're not hidden hurrah!");
		}
	}
	
%end
	
%hook UIStatusBarForegroundStyleAttributes
	- (id)textColorForStyle:(long long)arg1{
		%log;return %orig;
	}
	
	- (long long)legibilityStyle{
		long long tmp = %orig;
		NSLog(@"[]----[] %lld",tmp);
		return tmp;
	}
%end
	
%hook UIStatusBarForegroundView
	- (void)stopIgnoringData:(_Bool)arg1{
		NSLog(@"-- DID STOP --");
		%log;%orig;
	}
	
	- (void)startIgnoringData{
		NSLog(@"-- DID start --");
		%log;%orig;
	}
%end*/