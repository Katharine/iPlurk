//
//  EmoticonPanelController.m
//  iPlurk
//
//  Created on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import "EmoticonPanelController.h"


@implementation EmoticonPanelController
@synthesize webView;
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
    [super viewDidLoad];
	[webView setDelegate:self];
	NSMutableString *table = [[NSMutableString alloc] init];
	
	NSDictionary *allEmoticons = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoticons" ofType:@"plist"]];
	
	NSMutableArray *emoticons = [NSMutableArray arrayWithArray:[allEmoticons objectForKey:@"basic"]];
	float karma = [[[PlurkAPI sharedAPI] currentUser] karma];
	if(karma > 25.0) {
		[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"silver"]];
		if(karma > 50.0) {
			[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"gold"]];
			if(karma > 81.0) {
				[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"platinum_2"]];
				if(karma > 99.995) { // Because we all love floating point errors.
					[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"karma100"]];
				}
			}
		}
	}
	
	if([[PlurkAPI sharedAPI] hasTenFriends]) {
		[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"platinum"]];
	}
	
	allEmoticons = nil;
	
	NSString *emoticonPath = [NSString stringWithFormat:@"file://%@/statics/%%@", [[NSBundle mainBundle] resourcePath], nil];
	NSInteger rows = ceil([emoticons count] / 5.0); // Remember to divide by a floating point number or we get the result rounded down.
	for(NSInteger i = 0; i < rows; ++i) {
		[table appendString:@"<tr>"];
		for(NSInteger j = 0; j < 5; ++j) {
			NSInteger index = i * 5 + j;
			if(index >= [emoticons count]) break;
			NSDictionary *dict = [emoticons objectAtIndex:index];
			NSString *name = [dict objectForKey:@"name"];
			NSString *url = [NSString stringWithFormat:emoticonPath, [dict objectForKey:@"url"], nil];
			[table appendFormat:@"<td onclick=\"loadEmoticon(&quot;%@&quot;)\"><img src=\"%@\" onclick=\"loadEmoticon(&quot;%@&quot;)\" /></td>", name, url, name, nil];
		}
		[table appendString:@"</tr>"];
	}
	
	NSString *html = [NSString stringWithFormat:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EmoticonPicker" ofType:@"html"]], table, nil];
	
	[webView loadHTMLString:html baseURL:nil];
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
	[[self view] removeFromSuperview];
	[modaliser removeFromSuperview];
	[modaliser release];
}

- (void)closePanel {
	[webView stopLoading];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(diePeacefully:finished:context:)];
	[modaliser setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	[[self view] setFrame:CGRectMake(0, 420, 320, 254)];
	[UIView commitAnimations];
	[delegate performSelector:action withObject:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (BOOL)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type {
	if([[request URL] query] != nil) {
		[self emoticonChosen:[[request URL] query]];
		return NO;
	}
	return YES;
}

- (void)dealloc {
	if([webView isLoading]) [webView stopLoading];
	[webView release];
    [super dealloc];
}


@end
