#import <objc/runtime.h>
#import <substrate.h>

@interface UIStatusBarForegroundStyleAttributes
	- (id)tintColor;
@end

@interface UIStatusBarForegroundView
	@property(readonly, nonatomic) UIStatusBarForegroundStyleAttributes *foregroundStyle;
@end

@interface UIStatusBar{
	UIStatusBarForegroundView *_foregroundView;
}
	- (_Bool)isHidden;
@end