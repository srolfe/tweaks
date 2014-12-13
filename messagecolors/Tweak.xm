#import "messageColors.h"

NSMutableDictionary *colorPrefs;

// Manipulate colors on configuration
%hook CKBalloonView
	- (void)configureForMessagePart:(id)arg1{
		%orig;
		
		if ([arg1 respondsToSelector:@selector(color)]){
			int colorCode=[[NSString stringWithFormat:@"%d",[(CKChatItem *)arg1 color]] integerValue]; // Hack to get at color data
		
			if ([self respondsToSelector:@selector(gradientView)] && [self gradientView]!=nil){
				NSArray *colors;
		
				if (colorCode==0){ // SMS
					if ([colorPrefs objectForKey:@"smsColors"]!=nil){
						colors=[colorPrefs objectForKey:@"smsColors"];
					}
				}else if (colorCode==1 && ![arg1 didMask]){ // iMessage
					if ([colorPrefs objectForKey:@"imColors"]!=nil){
						colors=[colorPrefs objectForKey:@"imColors"];
					}
				}else{ // RECVD
					if ([colorPrefs objectForKey:@"rcvColors"]!=nil){
						colors=[colorPrefs objectForKey:@"rcvColors"];
					}
				}
				
				if (colors!=nil){
					// Fix single color bug
					if ([colors count]==1){
						colors=[NSArray arrayWithObjects:[colors objectAtIndex:0],[colors objectAtIndex:0],nil];
					}
					
					[[self gradientView] actuallySetColors:colors];
				}
			}
		}
	}
%end

// Needs a temporary key to hold mask data
static void *didMaskKey;

// Mask the received message bubble
%hook CKMessagePartChatItem
	- (BOOL)color{
		int color=[[NSString stringWithFormat:@"%d",%orig] integerValue]; // Hack to get at color data
		
		if (color==-1 && [colorPrefs objectForKey:@"rcvColors"]!=nil){
			objc_setAssociatedObject(self,&didMaskKey,[NSNumber numberWithInt:1],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			return 1;
		}else{
			return %orig;
		}
	}
	
	%new(b:v)
	- (BOOL)didMask{
		return [(NSNumber *)objc_getAssociatedObject(self,&didMaskKey) integerValue] || NO;
	}
%end

// Needs a temporary key to hold mask data
static void *didActuallySet;

// Disallow normal color setting
%hook CKGradientView
	// Lock down setColors if we set the colors
	- (void)setColors:(NSArray *)colors{
		NSNumber *theNum=(NSNumber *)objc_getAssociatedObject(self,&didActuallySet);
		if (theNum==nil || [theNum integerValue]==0){
			%orig(colors);
		}
	}
	
	// Go around setColors and lock it
	%new(v:@)
	- (void)actuallySetColors:(NSArray *)colors{
		objc_setAssociatedObject(self,&didActuallySet,[NSNumber numberWithInt:1],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		MSHookIvar<NSArray *>(self,"_colors")=colors;
	}
%end

static void loadPrefs(){
	colorPrefs=[[NSMutableDictionary alloc] init];
	
	// Load orig prefs
	CFPreferencesAppSynchronize(CFSTR("com.chewmieser.messageColors"));
	
	NSData *imDat=(__bridge NSData *)CFPreferencesCopyAppValue(CFSTR("imColorArray"),CFSTR("com.chewmieser.messageColors"));
	NSData *smsDat=(__bridge NSData *)CFPreferencesCopyAppValue(CFSTR("smsColorArray"),CFSTR("com.chewmieser.messageColors"));
	NSData *rcvDat=(__bridge NSData *)CFPreferencesCopyAppValue(CFSTR("rcvColorArray"),CFSTR("com.chewmieser.messageColors"));
	
	if (imDat!=nil){
		//[colorPrefs setObject:[[NSMutableArray alloc] init] forKey:@"imColors"];
		NSMutableArray *imColors=[[NSMutableArray alloc] init];
		
		NSArray *tmp=(NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:imDat];
		for (NSString *colorCode in tmp){
			// Parse hex color
			unsigned rgbValue=0;
			NSScanner *scanner=[NSScanner scannerWithString:colorCode];
			[scanner setScanLocation:1]; // bypass '#' character
			[scanner scanHexInt:&rgbValue];

			// Create UIColor
			[imColors addObject:[UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0]];
		}
		
		if ([imColors count]>0) [colorPrefs setObject:imColors forKey:@"imColors"];
	}
	
	if (smsDat!=nil){
		//[colorPrefs setObject:[[NSMutableArray alloc] init] forKey:@"imColors"];
		NSMutableArray *smsColors=[[NSMutableArray alloc] init];
		
		NSArray *tmp=(NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:smsDat];
		for (NSString *colorCode in tmp){
			// Parse hex color
			unsigned rgbValue=0;
			NSScanner *scanner=[NSScanner scannerWithString:colorCode];
			[scanner setScanLocation:1]; // bypass '#' character
			[scanner scanHexInt:&rgbValue];

			// Create UIColor
			[smsColors addObject:[UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0]];
		}
		
		if ([smsColors count]>0) [colorPrefs setObject:smsColors forKey:@"smsColors"];
	}
	
	if (rcvDat!=nil){
		//[colorPrefs setObject:[[NSMutableArray alloc] init] forKey:@"imColors"];
		NSMutableArray *rcvColors=[[NSMutableArray alloc] init];
		
		NSArray *tmp=(NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:rcvDat];
		for (NSString *colorCode in tmp){
			// Parse hex color
			unsigned rgbValue=0;
			NSScanner *scanner=[NSScanner scannerWithString:colorCode];
			[scanner setScanLocation:1]; // bypass '#' character
			[scanner scanHexInt:&rgbValue];

			// Create UIColor
			[rcvColors addObject:[UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0]];
		}
		
		if ([rcvColors count]>0) [colorPrefs setObject:rcvColors forKey:@"rcvColors"];
	}
}

static void PreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	loadPrefs();
}
	
%ctor{
	loadPrefs();
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChanged, CFSTR("com.chewmieser.messageColors.prefs-changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}