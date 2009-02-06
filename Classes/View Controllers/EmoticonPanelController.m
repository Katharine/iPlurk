//
//  EmoticonPanelController.m
//  iPlurk
//
//  Created on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import "EmoticonPanelController.h"


@implementation EmoticonPanelController
@synthesize tableController;
@synthesize delegate, action;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"Viewdidload %@", tableController);
    [super viewDidLoad];
	[tableController setDelegate:self];
	[tableController setAction:@selector(emoticonChosen:)];
	[tableController doSetup];
}

- (void)emoticonChosen:(NSString *)emoticon {
	[delegate performSelector:action withObject:emoticon];
	[self closePanel];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)animateIn {
	modaliser = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] retain];
	[modaliser setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	[[[self view] superview] insertSubview:modaliser belowSubview:[self view]];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[modaliser setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.2]];
	[[self view] setFrame:CGRectMake(0, 161, 320, 254)];
	[UIView commitAnimations];
}

- (void)diePeacefully:(NSString *)animation finished:(BOOL)finished context:(void *)context {
	//[[self view] removeFromSuperview];
	[modaliser removeFromSuperview];
	[modaliser release];
}

- (void)closePanel {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(diePeacefully:finished:context:)];
	[modaliser setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	[[self view] setFrame:CGRectMake(0, 420, 320, 254)];
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
