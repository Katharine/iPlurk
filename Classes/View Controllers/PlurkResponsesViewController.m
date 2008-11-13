//
//  PlurkResponsesViewController.m
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkResponsesViewController.h"


@implementation PlurkResponsesViewController
@synthesize firstPlurk, webView, avatarPath, emoticonPath, plurkAPI, delegate, connection;

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
	[[self navigationItem] setTitle:@"Plurk Responses"];
	if([firstPlurk ownerID] == [plurkAPI userID]) {
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(chooseOwnPlurkAction)] animated:NO];
	} else {
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(beginReply)] animated:NO];
	}
	[webView setBackgroundColor:[UIColor whiteColor]];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	if(!(connection = [plurkAPI requestResponsesToPlurk:[firstPlurk plurkID] delegate:self])) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't load responses" message:@"A request to get plurk responses could not be initiated." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[[self navigationController] popViewControllerAnimated:YES];
	}
	
	// Set up a loading screen.
	NSString *spinner = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"LargeWhiteProgressIndicator" ofType:@"gif"], nil];
	NSString *loadingScreen = [NSString stringWithFormat:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesLoading" ofType:@"html"]], spinner, nil];
	[webView loadHTMLString:loadingScreen baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	if(![self modalViewController]) {
		if([webView isLoading]) {
			[webView setDelegate:nil];
			[webView stopLoading];
		}
		NSLog(@"Attempting to cancel connection.");
		if(connection) {
			[plurkAPI cancelConnection:connection];
			connection = nil;
		}
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[self viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	if([self modalViewController]) return;
	[super viewWillAppear:animated];
	[webView setDelegate:self];
}

- (void)beginReply {
	WritePlurkTableViewController *controller = [[WritePlurkTableViewController alloc] initWithNibName:@"WritePlurkTableView" bundle:nil];
	UINavigationController *newController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller setPlurkToReplyTo:firstPlurk];
	[controller setPlurkAPI:plurkAPI];
	[self presentModalViewController:newController animated:YES];
	[controller release];
}

- (void)chooseOwnPlurkAction {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
													   delegate:self 
											  cancelButtonTitle:@"Cancel" 
										 destructiveButtonTitle:@"Delete Plurk"
											  otherButtonTitles:@"Edit Plurk", @"Reply To Plurk", nil
	];
	[sheet showInView:[self view]];
	[sheet release];
}

- (void)plurkResponseCompleted:(ResponsePlurk *)plurk {
	NSLog(@"Completed making response, appending...");
	NSString *content = [self processPlurkContent:[plurk content]];
	NSString *html = [[[NSString stringWithFormat:
						[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesSingleResponse" ofType:@"html"]],
						[plurk plurkID],
						[plurk userDisplayName],
						(([[plurk qualifier] length] < 2) ? @"" : [plurk qualifier]), 
						content,
						nil
					   ]
					   stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""
					  ]
					  stringByReplacingOccurrencesOfString:@"\n" withString:@""
	];
				
	NSString *script = [NSString stringWithFormat:@"var node = document.createElement('div'); node.innerHTML = \"%@\"; document.getElementById('responses').appendChild(node); node.scrollIntoView();", html, nil];
	[webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)receivedPlurkResponses:(NSArray *)responses {	
	NSString *htmlTemplate = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesDisplay" ofType:@"html"]];
	NSString *avatarURL = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"NoAvatarAvailable" ofType:@"png"], nil];
	NSString *realAvatarPath = [NSString stringWithFormat:@"%@/user-%d.gif", avatarPath, [firstPlurk ownerID], nil];
	if([[NSFileManager defaultManager] fileExistsAtPath:realAvatarPath]) {
		avatarURL = [NSString stringWithFormat:@"file://%@", realAvatarPath];
	}
	NSMutableString *responseHTML = [[NSMutableString alloc] init];
	if([responses count] > 0) {
		NSString *responseFormat = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesSingleResponse" ofType:@"html"]];
		
		NSInteger responseNum = 0;
		for(ResponsePlurk *response in responses) {
			[responseHTML appendFormat:responseFormat, responseNum, [response userDisplayName], (([[response qualifier] length] < 2) ? @"" : [response qualifier]), [response content], nil];
			++responseNum;
		}
	}
	NSString *html = [NSString stringWithString:[NSString stringWithFormat:htmlTemplate, [firstPlurk responsesSeen], avatarURL, [firstPlurk ownerDisplayName], ([[firstPlurk qualifier] length] < 2 ? @"" : [firstPlurk qualifier]), [firstPlurk content], responseHTML, nil]];
	[webView loadHTMLString:[self processPlurkContent:html] baseURL:nil];
	[firstPlurk setIsUnread:0];
	[firstPlurk setResponseCount:[responses count]];
	[firstPlurk setResponsesSeen:[firstPlurk responseCount]];
	NSLog(@"Finished rendering.");
}

- (NSString *)processPlurkContent:(NSString *)contentString {
	NSMutableString *content = [NSMutableString stringWithString:contentString];
	[content replaceOccurrencesOfString:@"http://static.plurk.com/static/emoticons/" withString:[NSString stringWithFormat:@"file://%@", emoticonPath, nil] options:NSLiteralSearch range:NSMakeRange(0, [content length])];
	[content replaceOccurrencesOfRegex:@"<a[^<>]+?href=\"([^<>]+?)\"[^<>]+?class=\"[^<>]*?pictureservices[^<>]*?\"[^<>]*?>[^<>]+?</a>" withString:@"<a href=\"$1\"><img src=\"$1\" class=\"pictureservices regeximg\"></a>"];
	return content;
}

- (void)connection:(NSURLConnection *)theConnection receivedNewPlurks:(NSArray *)plurks {
	if([firstPlurk isEqual:[plurks objectAtIndex:0]]) {
		Plurk *updated = [plurks objectAtIndex:0];
		firstPlurk.contentRaw = [updated contentRaw];
		firstPlurk.content = [updated content];
	}
	[[[(UINavigationController *)[self parentViewController] viewControllers] objectAtIndex:0] connection:theConnection receivedNewPlurks:plurks];
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('firstPlurkActualText').innerHTML = \"%@\";", [[self processPlurkContent:[firstPlurk content]] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if(navigationType == UIWebViewNavigationTypeOther) return YES;
	NSLog(@"UIWebView tried to load %@", [[request URL] absoluteString]);
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to quit iPlurk to follow this link?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
	
	if([[[request URL] host] hasSuffix:@"youtube.com"]) {
		if([[[request URL] path] isEqual:@"/watch"] || [[[request URL] host] hasPrefix:@"/v/"]) {
			currentURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com%@?%@", [[request URL] path], [[request URL] query]]];
			[sheet setTitle:@"Do you want to quit iPlurk to view this YouTube video in the YouTube app?"];
		}
	} else if([[[request URL] host] isEqual:@"phobos.apple.com"]) {
		currentURL = [request URL];
		[sheet setTitle:@"Do you want to quit iPlurk to view this on the iTunes store?"];
	} else if([[[request URL] host] isEqual:@"maps.google.com"] || [[[request URL] host] isEqual:@"ditu.google.com"]) {
		if([[[request URL] path] isEqual:@"/"] || [[[request URL] path] isEqual:@"/maps"] || [[[request URL] path] isEqual:@"/m"]) {
			currentURL = [request URL];
			[sheet setTitle:@"Do you want to quit iPlurk to view this map in the Maps app?"];
		}
	} else {
		[sheet release];
		sheet = nil;
		if([webView isLoading]) [webView stopLoading];
		WebPagePreviewController *controller = [[WebPagePreviewController alloc] initWithNibName:@"WebPagePreview" bundle:nil];
		[controller setRequestToLoad:request];
		[self presentModalViewController:controller animated:YES];
		[controller release];
	}
	if(sheet) {
		[currentURL retain];
		[sheet showInView:[self view]];
		[sheet release];
	}
	return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(currentURL) {
		if(buttonIndex != [actionSheet cancelButtonIndex]) {
			[[UIApplication sharedApplication] openURL:currentURL];
		}
		[currentURL release];
		currentURL = nil;
	} else if([firstPlurk ownerID] == [plurkAPI userID]) {
		// "What do you want to do?" sheet
		if(buttonIndex == [actionSheet cancelButtonIndex]) {
			return;
		} else if(buttonIndex == [actionSheet destructiveButtonIndex]) {
			[plurkAPI deletePlurk:[firstPlurk plurkID]];
			[[self navigationController] popViewControllerAnimated:YES];
			[delegate performSelector:@selector(removePlurk:) withObject:firstPlurk];
		} else if(buttonIndex == 1) {
			WritePlurkTableViewController *controller = [[WritePlurkTableViewController alloc] initWithNibName:@"WritePlurkTableView" bundle:nil];
			UINavigationController *newController = [[UINavigationController alloc] initWithRootViewController:controller];
			[controller setPlurkToEdit:firstPlurk];
			[controller setPlurkAPI:plurkAPI];
			[self presentModalViewController:newController animated:YES];
			[controller release];
		} else if(buttonIndex == 2) {
			[self beginReply];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)plurkHTTPRequestAborted:(NSError *)error {
	connection = nil;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't load plurk" 
													message:[NSString stringWithFormat:@"This plurk could not be loaded. Please try again later.\n\n%@ (%d)", [error localizedDescription], [error code], nil]  
												   delegate:nil 
										  cancelButtonTitle:@"Dismiss" 
										  otherButtonTitles:nil
	];
	[alert show];
	[alert release];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)dealloc {
	[firstPlurk release];
	[webView release];
	[avatarPath release];
	[emoticonPath release];
	[plurkAPI release];
	[connection release];
	if(currentURL) {
		[currentURL release];
	}
	if(![self modalViewController]) {
		[super dealloc];
	}
}


@end
