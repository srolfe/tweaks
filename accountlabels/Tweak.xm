#include "accountLabels.h"

// Stores the colors for each account globally
NSMutableDictionary *accountColors;

// Load / make colors
%hook MailAppController
	- (NSSet *)displayedAccounts{
		NSSet *tmp=%orig;
		
		// Load default
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		NSData *dat=[defaults objectForKey:@"com.chewmieser.accountLabels"];
		
		// Unarchive OR create dictionary
		if (dat!=nil){
			accountColors=[[NSMutableDictionary alloc] initWithDictionary:(NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:dat]];
		}else{
			accountColors=[[NSMutableDictionary alloc] init];
		}
		
		BOOL newAccounts=NO;
		
		// Iterate through accounts
		for (MailAccount *ma in tmp){
			NSString *displayName=[ma displayName];
			
			// Create random color if account not found
			if ([accountColors objectForKey:displayName]==nil){
				newAccounts=YES;
				UIColor *theColor=[UIColor colorWithRed:rand()/(float)RAND_MAX green:rand()/(float)RAND_MAX blue:rand()/(float)RAND_MAX alpha:1.0];
				[accountColors setObject:theColor forKey:displayName];
			}
		}
		
		// Save and synchronize
		if (newAccounts){
			[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:accountColors] forKey:@"com.chewmieser.accountLabels"];
			[defaults synchronize];
		}
		
		return tmp;
	}
%end

// Display in the mail view
%hook MailboxContentViewCell
	-(void)layoutSubviews{
		%orig;
		
		// Figure out the mailboxID
		NSString *mailboxAddress=[[[self message] account] displayName];
		
		if ([accountColors objectForKey:mailboxAddress]!=nil){
			// Static view to hold indicator
			_CellStaticView *sView=MSHookIvar<_CellStaticView *>(self,"_staticView");
		
			// Create view
			CGRect labelFrame=sView.frame;
			labelFrame.size.width=5.0;
			UIView *tmp=[[UIView alloc] initWithFrame:labelFrame];
			
			[tmp setBackgroundColor:(UIColor *)[accountColors objectForKey:mailboxAddress]];
			[sView addSubview:tmp];
		}
	}
%end

@interface ColorPickerViewController : UIViewController
@end
	
@implementation ColorPickerViewController
	- (void)viewDidLoad{
		[super viewDidLoad];
		
		[self.view setBackgroundColor:[UIColor colorWithWhite:0.25 alpha:0.75]];
		
		// Create overlay
		/*UIView *overlayView=[[UIView alloc] initWithFrame:self.view.frame];
		[overlayView setBackgroundColor:[UIColor grayColor]];
		[overlayView setAlpha:0.75];
		[self.view addSubview:overlayView];
		
		// Overlay constraints
		NSLayoutConstraint *OLC=[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
		NSLayoutConstraint *ORC=[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
		NSLayoutConstraint *OTC=[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
		NSLayoutConstraint *OBC=[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
		[self.view addConstraints:[NSArray arrayWithObjects:OLC,ORC,OTC,OBC,nil]];*/
		
		// Create colorPicker main view
		/*CGRect theFrame=self.view.frame;
		theFrame.origin.x+=20;
		theFrame.origin.y+=60;
		theFrame.size.width-=40;
		theFrame.size.height-=120;
		
		UIView *colorPicker=[[UIView alloc] initWithFrame:theFrame];
		[colorPicker setBackgroundColor:[UIColor whiteColor]];
		[self.view addSubview:colorPicker];*/
	}
	
	/*- (BOOL)shouldAutorotate{
		return YES;
	}
	
	- (NSUInteger)supportedInterfaceOrientations{
		return UIInterfaceOrientationMaskAll;
	}*/
@end

// Display in the main pane
%hook MailboxTableCell
	- (void)layoutSubviews{
		%orig;
		
		// Figure out the mailboxID
		UILabel *title=MSHookIvar<UILabel *>(self,"_titleLabel");
		NSString *mailboxAddress=[title text];
		
		if ([accountColors objectForKey:mailboxAddress]!=nil){
			// Handle expand/collapse color view
		    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeIt:)];
			[recognizer setDirection:UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight];
			[self addGestureRecognizer:recognizer];
			recognizer.delegate = self;
			
			// Create view rect
			CGRect labelFrame=[[self contentView] frame];
			if ([self hasLeftAccessory]==YES){
				labelFrame.size.width=35.0;
			}else{
				labelFrame.size.width=5.0;
			}
		
			// Find view
			UIView *indicatorView;
			BOOL found=NO;
			for (UIView *theView in [self contentView].subviews){
				if (theView.tag==487){
					found=YES;
					indicatorView=theView;
					[indicatorView setFrame:labelFrame];
				}
			}
		
			// Create view if not found
			if (!found){
				indicatorView=[[UIView alloc] initWithFrame:labelFrame];
				[indicatorView setTag:487];
			}
		
			// Setup tap gesture
			if ([self hasLeftAccessory]==YES){
				UITapGestureRecognizer *rec=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBox:)];
				[indicatorView addGestureRecognizer:rec];
				rec.delegate=self;
			}
		
			// Set the background and add to contentView if needed
			[indicatorView setBackgroundColor:(UIColor *)[accountColors objectForKey:mailboxAddress]];
			if (!found) [[self contentView] addSubview:indicatorView];
		}
	}
	
	%new(v:@)
	- (void)swipeIt:(UISwipeGestureRecognizer *)gestureRecognizer{
		[UIView animateWithDuration:0.25 animations:^{
			[self setHasLeftAccessory:![self hasLeftAccessory]];
			[self layoutSubviews];
		}];
	}
	
	%new(v:@)
	- (void)didTapBox:(UITapGestureRecognizer *)gestureRecognizer{
		UIViewController *rootVC=[[[UIApplication sharedApplication] keyWindow] rootViewController];
		/*UIViewController *tmpVC=[[UIViewController alloc] init];
		tmpVC.view.frame=rootVC.view.frame;
		//UIView *tmp=[[UIView alloc] initWithFrame:rootVC.view.frame];
		[tmpVC.view setBackgroundColor:[UIColor redColor]];
		
		[rootVC.view addSubview:tmpVC.view];*/
		
		
		// Main VC
		ColorPickerViewController *colorPickerVC=[[ColorPickerViewController alloc] init];
		colorPickerVC.view.frame=rootVC.view.frame;
		[rootVC.view addSubview:colorPickerVC.view];
		
		/*NSLayoutConstraint *OLC=[NSLayoutConstraint constraintWithItem:colorPickerVC.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootVC.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
		NSLayoutConstraint *ORC=[NSLayoutConstraint constraintWithItem:colorPickerVC.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:rootVC.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
		NSLayoutConstraint *OTC=[NSLayoutConstraint constraintWithItem:colorPickerVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootVC.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
		NSLayoutConstraint *OBC=[NSLayoutConstraint constraintWithItem:colorPickerVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:rootVC.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
		[rootVC.view addConstraints:[NSArray arrayWithObjects:OLC,ORC,OTC,OBC,nil]];*/
		
		// Create overlay first
		/*
		
		// Set frame
		CGRect theFrame=rootVC.view.frame;
		theFrame.origin.x+=20;
		theFrame.origin.y+=60;
		theFrame.size.width-=40;
		theFrame.size.height-=120;
		
		UIView *colorPicker=[[UIView alloc] initWithFrame:theFrame];
		[colorPicker setBackgroundColor:[UIColor whiteColor]];
		
		[rootVC.view addSubview:colorPicker];*/
		
		
		/*UIAlertController *setColor=[UIAlertController alertControllerWithTitle:@"Set Color" message:@"Enter a hex color code" preferredStyle:UIAlertControllerStyleAlert];
	    UIAlertAction *setButton=[UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
			UITextField *textField=setColor.textFields[0];
			[self setColor:textField.text];
		}];
		
		UIAlertAction *cancelButton=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
			[setColor dismissViewControllerAnimated:YES completion:nil];
			[self swipeIt:nil];
		}];
		
		[setColor addAction:cancelButton];
		[setColor addAction:setButton];
		
		[setColor addTextFieldWithConfigurationHandler:^(UITextField *textField){
			textField.text=@"#";
			textField.keyboardType=UIKeyboardTypeDefault;
		}];
		
		[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:setColor animated:YES completion:nil];*/
	}
	
	%new(v:@)
	- (void)setColor:(NSString *)hexCode{
		UILabel *title=MSHookIvar<UILabel *>(self,"_titleLabel");
		NSString *mailboxAddress=[title text];
		
		// Parse hex color
		unsigned rgbValue=0;
		NSScanner *scanner=[NSScanner scannerWithString:hexCode];
		[scanner setScanLocation:1]; // bypass '#' character
		[scanner scanHexInt:&rgbValue];

		// Create UIColor
		[accountColors setObject:[UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0] forKey:mailboxAddress];
		
		// Save to userdefaults
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:accountColors] forKey:@"com.chewmieser.accountLabels"];
		[defaults synchronize];
		
		// Animate close
		[UIView animateWithDuration:0.25 animations:^{
			[self setHasLeftAccessory:NO];
			[self layoutSubviews];
		} completion:^(BOOL finished){
			[[self _tableView] reloadData];
		}];
	}
%end