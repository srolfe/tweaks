@interface CKChatItem : NSObject
	@property(readonly, nonatomic) BOOL color;
@end
	
@interface CKChatItem (messageColors)
	- (BOOL)didMask;
@end

@interface CKGradientView : UIView
	@property(retain, nonatomic) NSArray *colors;
@end
	
@interface CKGradientView (messageColors)
	- (void)actuallySetColors:(NSArray *)colors;
@end
	
@interface CKBalloonView : UIView
	@property(retain, nonatomic) CKGradientView *gradientView;
@end