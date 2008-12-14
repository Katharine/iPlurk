//
//  SetupViewController.m
//  iPlurk
//
//  Created on 10/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "SetupViewController.h"


@implementation SetupViewController
@synthesize usernameField, passwordField, doneButton, origin;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)viewWillAppear:(BOOL)flag {
	//NSLog(@"SetupViewController will appear.");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:@"plurk_username"];
	if(username == nil) username = @"";
	NSString *password = [defaults stringForKey:@"plurk_password"];
	if(password == nil) password = @"";
	[usernameField setText:username];
	[passwordField setText:password];
	if(![username length]) [usernameField becomeFirstResponder];
	//NSLog(@"Done appearing");
}

- (void)saveLoginDetails {
	if(![[usernameField text] length] || ![[passwordField text] length]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"More, please!" message:@"We need you to enter both your username and password to continue." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	[origin performSelector:@selector(userHasSetNewUsername:andPassword:) withObject:[usernameField text] withObject:[passwordField text]];
	[self dismissModalViewControllerAnimated:YES];
}

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
	[usernameField release];
	[passwordField release];
	[doneButton release];
}


@end
