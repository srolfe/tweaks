#import <objc/runtime.h>
#import <substrate.h>
#import <QuartzCore/QuartzCore.h>
//#import <LSStatusBarItem.h>

// Time cloaking functionality
@interface SBMainStatusBarStateProvider
	+ (id)sharedInstance;
	- (void)enableTime:(_Bool)arg1 crossfade:(_Bool)arg2 crossfadeDuration:(double)arg3;
@end

// Method injection
@interface SBHUDController
	- (id)modifyHUD:(id)view;
	- (CGRect)calculateFrame:(CGRect)baseFrame;
@end
	
@interface UIStatusBar
	@property(retain, nonatomic) UIColor *foregroundColor;
	@property(nonatomic) long long legibilityStyle;
	- (id)activeTintColor;
@end
	
@interface SBHUDView : UIView
@end
	
	@interface notify:NSObject{
		long long legibility;
	}

		@property (nonatomic) long long legibility;
	@end

UIInterfaceOrientation orient;
UIColor *statusStyle;
UIColor *springColor;
BOOL sbStatus;

// Logs when orientation changes to orient
%hook SBUIController
	
	- (void)activeInterfaceOrientationWillChangeToOrientation:(long long)arg1{
		orient=arg1;
		%orig;
	}
	
%end

// Main hook
%hook SBHUDController
	
	// Modify HUD view on presentation
	- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2{ %orig([self modifyHUD:arg1], arg2); }
	- (void)presentHUDView:(id)arg1{ %orig([self modifyHUD:arg1]); }
	
	// Manually re-center HUD view
	- (void)_recenterHUDView{
		UIView *HUD = MSHookIvar<UIView *>(self,"_hudView");
		HUD.frame=[self calculateFrame:HUD.frame];
	}
	
	// Show time on tear down
	- (void)_tearDown{
		[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:YES crossfade:NO crossfadeDuration:0];
		%orig;
	}
	
	// HUD manipulation
	%new(@@:@)
	- (id)modifyHUD:(SBHUDView *)view{
		SBHUDView *tmp=view;
		
		// Disable parallax effect
		for (UIMotionEffect *mo in tmp.motionEffects){
			[tmp removeMotionEffect:mo];
		}
		
		// Subview manipulation
		for (id t in tmp.subviews){
			// Remove backdrop, if available
			if ([NSStringFromClass([t class]) isEqualToString:@"_UIBackdropView"]){
				[t removeFromSuperview];
			}
			
			// Manipulate main view
			if ([NSStringFromClass([t class]) isEqualToString:@"UIView"]){
				/*UIView *tt=(UIView *)t;
				
				for (UIView *zz in tt.subviews){
					[zz removeFromSuperview];
				}*/
				
				/*for (CALayer *ww in tt.layer.sublayers){
					ww.masksToBounds = YES;
					ww.cornerRadius=1.0;
					ww.borderColor=[[UIColor redColor] CGColor];
					ww.borderWidth=1.0;
				}*/
				
				//tt.layer.masksToBounds = NO;
				//tt.layer.shadowOffset = CGSizeMake(0, 1);
				//tt.layer.shadowRadius = 2;
				//tt.layer.shadowOpacity = 0.8;
			}
		}
		
		// Reset frame
		tmp.frame=[self calculateFrame:tmp.frame];
		
		// Hide time
		[[objc_getClass("SBMainStatusBarStateProvider") sharedInstance] enableTime:NO crossfade:NO crossfadeDuration:0];
		//LSStatusBarItem *c = [[LSStatusBarItem alloc] initWithIdentifier:@"statusvol.Main" alignment:StatusBarAlignmentCenter];
		
		// Return view
		return tmp;
	}
	
	// Read orientation, calculate frame
	%new(@@:@)
	- (CGRect)calculateFrame:(CGRect)baseFrame{
		int width=0;
		
		if (UIInterfaceOrientationIsLandscape(orient)){
			width = [[UIScreen mainScreen] bounds].size.height / 2;
		}else{
			width = [[UIScreen mainScreen] bounds].size.width / 2;
		}
		
		return CGRectMake(
			(
				width
			)-(
				baseFrame.size.width / 2
			)+0.75,
			-126,
			baseFrame.size.width,
			baseFrame.size.height
		);
	}
	
%end

%hook SBHUDView
	
	- (id)_blockColorForValue:(float)arg1{
		UIColor *tmp=(UIColor *)%orig;
		CGFloat white, alpha;
		
		[tmp getWhite:&white alpha:&alpha];
		
		/*if (alpha == 0){
			alpha = 0.25;
		}*/
		
		/*if (sbStatus){
			[springColor getWhite:&white alpha:nil];
		}else{
			if (statusStyle == UIStatusBarStyleDefault){
				white = 0.0;
			}else{
				white = 1.0;
			}
		}*/
		
		[statusStyle getWhite:&white alpha:nil];
		
		tmp = [UIColor colorWithWhite:white alpha:alpha];
		
		return tmp;
	}
	
	- (void)_updateBlockView:(UIView *)arg1 value:(float)arg2 blockSize:(struct CGSize)arg3 point:(struct CGPoint)arg4{
		for (UIView *tmp in arg1.subviews){
			tmp.layer.masksToBounds=YES;
			tmp.layer.cornerRadius=2.75;
			tmp.frame=CGRectMake(tmp.frame.origin.x,tmp.frame.origin.y,5.5,5.5);
			
			CGFloat white;
			[statusStyle getWhite:&white alpha:nil];
			
			/*CGFloat white;
			if (sbStatus){
				[springColor getWhite:&white alpha:nil];
			}else{
				if (statusStyle == UIStatusBarStyleDefault){
					white = 0.0;
				}else{
					white = 1.0;
				}
			}*/
		
			UIColor *t = [UIColor colorWithWhite:white alpha:1.0];
			
			tmp.layer.borderColor=[t CGColor];
			tmp.layer.borderWidth=0.5;
		}
		
		%orig(arg1,arg2,arg3,arg4);
	}
	
%end
	
%hook SBApplication
	
	/*- (long long)effectiveStatusBarStyle{
		statusStyle=%orig;
		return statusStyle;
	}*/
	
%end
	
%hook SpringBoard
	
	//- (void)showSpringBoardStatusBar{ sbStatus=YES; %orig; }
	//- (void)hideSpringBoardStatusBar{ sbStatus=NO; %orig; }
	
	- (long long)statusBar:(UIStatusBar *)arg1 styleForRequestedStyle:(long long)arg2 overrides:(int)arg3{
		springColor = [arg1 foregroundColor];
		return %orig;
	}
	
%end

@interface statusvol : NSObject
	- (void)didReceiveNotification:(NSNotification *)notification;
@end

@implementation statusvol
	
	- (void)didReceiveNotification:(NSNotification *)notification{
		statusStyle=[notification object];
	}
	
@end
	
__attribute__((constructor)) static void init() {
	statusvol *main=[[statusvol alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:main selector:@selector(didReceiveNotification:) name:@"statusvol_NNC" object:nil];
}