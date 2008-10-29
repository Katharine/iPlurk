//
//  SetupViewController.h
//  iPlurk
//
//  Created on 10/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface SetupViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIButton *doneButton;
	RootViewController *origin;
}

@property(nonatomic, retain) UITextField *usernameField;
@property(nonatomic, retain) UITextField *passwordField;
@property(nonatomic, retain) UIButton *doneButton;
@property(nonatomic, retain) RootViewController *origin;

- (IBAction)saveLoginDetails;

@end
