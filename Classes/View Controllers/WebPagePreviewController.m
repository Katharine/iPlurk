//
//  WebPagePreviewController.m
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "WebPagePreviewController.h"


@implementation WebPagePreviewController
@synthesize requestToLoad, webView;

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


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	[[self navigationItem] setTitle:@"Loading..."]; 
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[webView setBackgroundColor:[UIColor whiteColor]];
	[webView loadRequest:requestToLoad];
}

- (IBAction)openSafari {
	[webView setDelegate:nil];
	if([webView isLoading]) [webView stopLoading];
	[[UIApplication sharedApplication] openURL:[[webView request] URL]];
}

- (IBAction)closeView {
	if([webView isLoading]) {
		[webView stopLoading];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	[webView setDelegate:nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	[[self navigationItem] setTitle:[theWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Error"
						  message:[NSString stringWithFormat:@"The page you were trying to load couldn't be opened:\n\n%@ (%d)", [error localizedDescription], [error code], nil]
						  delegate:self
						  cancelButtonTitle:@"Dismiss" 
						  otherButtonTitles:nil
						  ];
	[alert show];
	[alert release];
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self closeView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	if([webView isLoading]) [webView stopLoading];
	[webView setDelegate:nil];
	[webView release];
    [super dealloc];
}


@end
