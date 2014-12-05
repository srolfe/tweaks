@interface _UILegibilityLabel : UIView
	- (id)initWithSettings:(id)arg1 strength:(float)arg2 string:(id)arg3 font:(id)arg4;
@end
	
@interface _UILegibilitySettings : NSObject
	- (id)initWithContentColor:(id)arg1 contrast:(float)arg2;
	- (id)initWithStyle:(int)arg1 primaryColor:(id)arg2 secondaryColor:(id)arg3 shadowColor:(id)arg4;
	+ (id)sharedInstanceForStyle:(int)arg1;
	- (void)setSecondaryColor:(id)arg1;
	- (void)setPrimaryColor:(id)arg1;
@end

%hook _UILegibilityLabel
	- (id)initWithSettings:(id)arg1 strength:(float)arg2 string:(id)arg3 font:(id)arg4{
		id tmp=%orig;
		
		//_UILegibilitySettings *legSet=arg1;
		
		NSLog(@"!---- leg: %@ %@ %@ %f",arg1,tmp,arg3,arg2);
		return tmp;
	}
	
	- (id)initWithSettings:(id)arg1 strength:(float)arg2 string:(id)arg3 font:(id)arg4 options:(int)arg5{
		id tmp=%orig;
		
		//_UILegibilitySettings *legSet=arg1;
		
		NSLog(@"!---- OPT: %@ %@ %@ %f %d",arg1,tmp,arg3,arg2,arg5);
		return tmp;
	}
%end
	
%hook _UILegibilityView
	- (void)updateForChangedSettings:(id)arg1{
		%orig;
		NSLog(@"!--- UCS %@",arg1);
	}
%end
	
/*%hook _UILegibilitySettings
	+ (id)sharedInstanceForStyle:(int)arg1{
		NSLog(@"!-- Style requsted: %d",arg1);
		return %orig;
	}
%end*/