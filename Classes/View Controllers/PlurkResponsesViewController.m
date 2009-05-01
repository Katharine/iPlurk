//
//  PlurkResponsesViewController.m
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkResponsesViewController.h"


@implementation PlurkResponsesViewController
@synthesize firstPlurk, webView, delegate, connection, plurkIDToLoad;

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
	
	[webView setBackgroundColor:[UIColor whiteColor]];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// Set up a loading screen.
	NSString *spinner = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] pathForResource:@"LargeWhiteProgressIndicator" ofType:@"gif"], nil];
	NSString *loadingScreen = [NSString stringWithFormat:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesLoading" ofType:@"html"]], spinner, nil];
	[webView loadHTMLString:loadingScreen baseURL:nil];
	
	if(firstPlurk) {
		[self finishUISetup];
	} else if(plurkIDToLoad > 0) {
		[[PlurkAPI sharedAPI] requestPlurksByIDs:[NSArray arrayWithObject:[NSNumber numberWithInteger:plurkIDToLoad]] delegate:self];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	if(![self modalViewController]) {
		if([webView isLoading]) {
			[webView setDelegate:nil];
			[webView stopLoading];
		}
		//NSLog(@"Attempting to cancel connection.");
		if(connection) {
			[[PlurkAPI sharedAPI] cancelConnection:connection];
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

- (void)finishUISetup {
	if([firstPlurk ownerID] == [[PlurkAPI sharedAPI] userID]) {
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(chooseOwnPlurkAction)] animated:YES];
	} else {
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(beginReply)] animated:YES];
		if([firstPlurk noComments]) {
			[[[self navigationItem] rightBarButtonItem] setEnabled:FALSE];
		}
	}
	if(!(connection = [[PlurkAPI sharedAPI] requestResponsesToPlurk:[firstPlurk plurkID] delegate:self])) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't load responses" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[[self navigationController] popViewControllerAnimated:YES];
	}
}

- (void)beginReply {
	WritePlurkTableViewController *controller = [[WritePlurkTableViewController alloc] initWithNibName:@"WritePlurkTableView" bundle:nil];
	UINavigationController *newController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller setPlurkToReplyTo:firstPlurk];
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
	//NSLog(@"Completed making response, appending...");
	NSString *content = [self processPlurkContent:[plurk content]];
	NSString *qualifier = [[Qualifiers sharedQualifiers] translateQualifier:[plurk qualifier] to:[firstPlurk lang]];
	if(qualifier == nil) qualifier = [plurk qualifier];
	NSString *html = [[[NSString stringWithFormat:
						[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesSingleResponse" ofType:@"html"]],
						[plurk plurkID],
						[plurk plurkID],
						[[PlurkAPI sharedAPI] userName],
						[plurk userDisplayName],
						[plurk qualifier],
						qualifier, 
						content,
						nil
					   ]
					   stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""
					  ]
					  stringByReplacingOccurrencesOfString:@"\n" withString:@""
	];
	[firstPlurk setResponseCount:[firstPlurk responseCount] + 1];
	[firstPlurk setResponsesSeen:[firstPlurk responseCount]];
	NSString *script = [NSString stringWithFormat:@"var node = document.createElement('div'); node.innerHTML = \"%@\"; document.getElementById('responses').appendChild(node); node.scrollIntoView();", html, nil];
	[webView stringByEvaluatingJavaScriptFromString:script];
	UserTimelineTableViewController *controller = [[[self navigationController] viewControllers] objectAtIndex:0];
	[controller respondedToPlurk:firstPlurk];
}

- (void)receivedPlurkResponses:(NSArray *)responses withResponders:(NSDictionary *)responders {	
	NSString *htmlTemplate = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesDisplay" ofType:@"html"]];
	NSString *avatarURL;
	
	UIImage *image = [[ProfileImageCache mainCache] retrieveImageForUser:[firstPlurk ownerID]];
	if(image != nil) {
		avatarURL = [NSString stringWithFormat:@"data:image/png;base64,%@", [UIImagePNGRepresentation(image) base64Encoding], nil];
	} else {
		avatarURL = [NSString stringWithFormat:@"data:image/png;base64,%@", [UIImagePNGRepresentation([UIImage imageNamed:@"DefaultAvatarImage.png"]) base64Encoding], nil];
	}
	
	NSMutableString *responseHTML = [[NSMutableString alloc] init];
	if([responses count] > 0) {
		NSString *responseFormat = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PlurkResponsesSingleResponse" ofType:@"html"]];
		
		NSInteger responseNum = 0;
		for(ResponsePlurk *response in responses) {
			NSString *qualifier = [[Qualifiers sharedQualifiers] translateQualifier:[response qualifier] to:[firstPlurk lang]];
			if(qualifier == nil) qualifier = [response qualifier];
			// We leave this as zero if we can't delete the thing (i.e. it's not our response and not our plurk).
			// This is because the JS needs to know what to be excited about.
			NSInteger responseID = 0;
			if([response userID] == [[PlurkAPI sharedAPI] userID] || [firstPlurk ownerID] == [[PlurkAPI sharedAPI] userID]) {
				responseID = [response plurkID];
			}
			[responseHTML appendFormat:responseFormat, responseNum, responseID, [response userNickName], [response userDisplayName], [response qualifier], qualifier, [response content], nil];
			++responseNum;
		}
	}
	
	// Try fixing up the @nicknames to be @Display Names.
	NSInteger position = 0;
	NSRange range;
	NSMutableArray *namesToDo = [[NSMutableArray alloc] init];
	
	while((range = [responseHTML rangeOfRegex:@"<a href=\"http://www.plurk.com/([a-zA-Z0-9]+)\" class=\"ex_link\">.+?</a>" options:RKLNoOptions inRange:NSMakeRange(position, [responseHTML length] - position) capture:1 error:NULL]).location != NSNotFound) {
		NSString *nickname = [responseHTML substringWithRange:range];
		if(nickname && ![namesToDo containsObject:nickname]) {
			[namesToDo addObject:nickname];
		}
		position = range.location + range.length;
	}
	
	for(NSString *nickname in namesToDo) {
		NSString *displayName = [responders objectForKey:nickname];
		if(displayName && ![displayName isEqualToString:nickname]) {
			[responseHTML replaceOccurrencesOfString:[NSString stringWithFormat:@"<a href=\"http://www.plurk.com/%@\" class=\"ex_link\">%@</a>", nickname, nickname, nil] withString:[NSString stringWithFormat:@"<a href=\"http://www.plurk.com/%@\" class=\"ex_link\">%@</a>", nickname, displayName] options:NSLiteralSearch range:NSMakeRange(0, [responseHTML length])];
		}
	}
	
	// Check if we should highlight qualifiers. It's inverted because if the user has not shown a preference,
	// this'll be NO, and we want the default to be YES. The preference switch is inverted incidentally - 
	// ON = NO and OFF = YES. Hooray weirdness.
	BOOL doNotHighlightQualifiers = [[[NSUserDefaults standardUserDefaults] stringForKey:@"highlight_qualifiers"] isEqualToString:@"0"];
	
	NSString *css = !doNotHighlightQualifiers ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Qualifiers" ofType:@"css"]] : @"";
	NSString *qualifier = [[Qualifiers sharedQualifiers] translateQualifier:[firstPlurk qualifier] to:[firstPlurk lang]];
	if(qualifier == nil) qualifier = [firstPlurk qualifier];
	NSString *html = [NSString stringWithString:[NSString stringWithFormat:htmlTemplate, css, [firstPlurk responsesSeen], avatarURL, [firstPlurk ownerNickName], [firstPlurk ownerDisplayName], [firstPlurk qualifier], qualifier, [firstPlurk content], responseHTML, nil]];
	[webView loadHTMLString:[self processPlurkContent:html] baseURL:[NSURL URLWithString:@"http://www.plurk.com/"]];
	[firstPlurk setIsUnread:0];
	[firstPlurk setResponseCount:[responses count]];
	[firstPlurk setResponsesSeen:[firstPlurk responseCount]];
	//NSLog(@"Finished rendering.");
}


- (NSString *)processPlurkContent:(NSString *)contentString {
	NSMutableString *content = [NSMutableString stringWithString:[PlurkFormatting addSmiliesToPlurk:contentString]];
	[content replaceOccurrencesOfRegex:@"<a[^<>]+?href=\"([^<>]+?)\"[^<>]+?class=\"[^<>]*?pictureservices[^<>]*?\"[^<>]*?>[^<>]+?</a>" withString:@"<a href=\"$1\"><img src=\"$1\" class=\"pictureservices regeximg\"></a>"];
	
	// Convert all /user/ references to / references, then convert all / references to /user/ references.
	// This is to make sure we don't break existing /user/ references, but add all the / references, too.
	// The distinction is used to enable things and stuff.
	[content replaceOccurrencesOfRegex:@"<a href=\"http://www.plurk.com/user/([a-zA-Z0-9_]+)\" class=\"ex_link\">(.+?)</a>"
							withString:@"<a href=\"http://www.plurk.com/$1\" class=\"ex_link\">$2</a>"
								 range:NSMakeRange(0, [content length])
	];
	[content replaceOccurrencesOfRegex:@"<a href=\"http://www.plurk.com/([a-zA-Z0-9_]+)\" class=\"ex_link\">(.+?)</a>"
							withString:@"<a href=\"http://www.plurk.com/user/$1\" class=\"ex_link\">$2</a>"
								 range:NSMakeRange(0, [content length])
	];
	
	// iPhone 2.0 software (or lower) doesn't play nice with YouTube embeds.
	if(![[[UIDevice currentDevice] systemVersion] isEqual:@"2.0"]) {
		// Make YouTube videos playable without exiting iPlurk. For extra marks, put a label next to it.
		[content replaceOccurrencesOfRegex:@"<a href=\"http://[a-zA-Z]+\\.youtube\\.com/watch\\?v=([a-zA-Z0-9]+).*?\".*?>.+?alt=\"(.+?)\".+?</a>"
								withString:@"<div class=\"youtube\"><embed src=\"http://www.youtube.com/v/$1\" type=\"application/x-shockwave-flash\" width=\"60\" height=\"45\"> <span>$2</span></div>"
									 range:NSMakeRange(0, [content length])
		];
	}
	
	return content;
}

- (void)connection:(NSURLConnection *)theConnection receivedNewPlurks:(NSArray *)plurks {
	if(firstPlurk) {
		if([plurks count] > 0 && [firstPlurk isEqual:[plurks objectAtIndex:0]]) {
			Plurk *updated = [plurks objectAtIndex:0];
			firstPlurk.contentRaw = [updated contentRaw];
			firstPlurk.content = [updated content];
		}
		[[[(UINavigationController *)[self parentViewController] viewControllers] objectAtIndex:0] connection:theConnection receivedNewPlurks:plurks];
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('firstPlurkActualText').innerHTML = \"%@\";", [[self processPlurkContent:[firstPlurk content]] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
	} else {
		if([plurks count] == 0) {
			// The plurk presumably does not exist.
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Plurk Not Found" message:@"This plurk does not exist!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			// I hate BOOLs.
			NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[[self navigationController] methodSignatureForSelector:@selector(popViewControllerAnimated:)]];
			[invoke setTarget:[self navigationController]];
			[invoke setSelector:@selector(popViewControllerAnimated:)];
			BOOL yes = YES;
			[invoke setArgument:&yes atIndex:2];
			[invoke performSelector:@selector(invoke) withObject:nil afterDelay:1];
		} else {
			// The plurk does exist! :p
			firstPlurk = [[plurks objectAtIndex:0] retain];
			[self finishUISetup];
		}
	}
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// Check for internal actions.
	if([[[request URL] scheme] isEqualToString:@"iplurkinternal"]) {
		if([[[request URL] host] isEqualToString:@"deleteresponse"]) {
			[[PlurkAPI sharedAPI] deleteResponse:[[[request URL] query] intValue] toPlurk:[firstPlurk plurkID]];
			[firstPlurk setResponseCount:[firstPlurk responseCount] - 1];
			[firstPlurk setResponsesSeen:[firstPlurk responseCount]];
		}
		return NO;
	}
	
	if(navigationType == UIWebViewNavigationTypeOther) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		return YES;
	}
	//NSLog(@"UIWebView tried to load %@", [[request URL] absoluteString]);
	UIActionSheet *sheet = nil; 
	
	// The YouTube case should never happen, but we leave this to catch anything missed earlier.
	if([[[request URL] host] hasSuffix:@"youtube.com"]) {
		if([[[request URL] path] isEqual:@"/watch"] || [[[request URL] host] hasPrefix:@"/v/"]) {
			currentURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com%@?%@", [[request URL] path], [[request URL] query], nil]];
			sheet = [[UIActionSheet alloc] initWithTitle:@"Opening this YouTube video will close iPlurk." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Watch YouTube Video", nil];
		}
	} else if([[[request URL] host] isEqual:@"phobos.apple.com"] || [[[request URL] host] isEqual:@"itunes.apple.com"]) {
		currentURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://phobos.apple.com%@?%@", [[request URL] path], [[request URL] query], nil]];
		sheet = [[UIActionSheet alloc] initWithTitle:@"Following this link will close iPlurk and launch the iTunes Store" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Visit the iTunes Store", nil];
	} else if(([[[request URL] host] isEqual:@"itunes.com"] || [[[request URL] host] hasSuffix:@".itunes.com"]) && [[[request URL] path] hasPrefix:@"/app/"]) {
		currentURL = [request URL];
		sheet = [[UIActionSheet alloc] initWithTitle:@"Following this link will close iPlurk and open the App Store" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open the App Store", nil];
	} else if([[[request URL] host] isEqual:@"maps.google.com"] || [[[request URL] host] isEqual:@"ditu.google.com"]) {
		if([[[request URL] path] isEqual:@"/"] || [[[request URL] path] isEqual:@"/maps"] || [[[request URL] path] isEqual:@"/m"]) {
			currentURL = [request URL];
			sheet = [[UIActionSheet alloc] initWithTitle:@"This link will close iPlurk and open Maps" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open Map", nil];
		}
	} else if([[[request URL] host] isEqualToString:@"www.plurk.com"] && [[[request URL] path] hasPrefix:@"/p/"]) {
		UserTimelineTableViewController *controller = [[[self navigationController] viewControllers] objectAtIndex:0];
		[controller displayPlurkWithBase36ID:[[[request URL] path] substringFromIndex:3]];
	} else if([[[request URL] host] isEqualToString:@"www.plurk.com"] && [[[request URL] path] hasPrefix:@"/user/"]) {
		UserTimelineTableViewController *controller = [[[self navigationController] viewControllers] objectAtIndex:0];
		[controller displayAlternateTimeline:[[[request URL] path] substringFromIndex:6]];
	} else {
		[sheet release];
		sheet = nil;
		if([webView isLoading]) [webView stopLoading];
		// Check if we want to change the URL (e.g. for Flickr images)
		if([[[request URL] host] hasSuffix:@"flickr.com"]) {
			request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.flickr.com/#%@", [[request URL] path]]]];
		}
		WebPagePreviewController *controller = [[WebPagePreviewController alloc] initWithNibName:@"WebPagePreview" bundle:nil];
		UINavigationController *newController = [[UINavigationController alloc] initWithRootViewController:controller];
		[controller navigationItem].leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:controller action:@selector(closeView)];
		[controller navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Compass.png"] style:UIBarButtonItemStylePlain target:controller action:@selector(openSafari)];
		[controller setRequestToLoad:request];
		[self presentModalViewController:newController animated:YES];
		[controller release];
		[newController release];
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
	} else if([firstPlurk ownerID] == [[PlurkAPI sharedAPI] userID]) {
		// "What do you want to do?" sheet
		if(buttonIndex == [actionSheet cancelButtonIndex]) {
			return;
		} else if(buttonIndex == [actionSheet destructiveButtonIndex]) {
			[[PlurkAPI sharedAPI] deletePlurk:[firstPlurk plurkID]];
			[[self navigationController] popViewControllerAnimated:YES];
			[delegate performSelector:@selector(removePlurk:) withObject:firstPlurk];
		} else if(buttonIndex == 1) {
			WritePlurkTableViewController *controller = [[WritePlurkTableViewController alloc] initWithNibName:@"WritePlurkTableView" bundle:nil];
			UINavigationController *newController = [[UINavigationController alloc] initWithRootViewController:controller];
			[controller setPlurkToEdit:firstPlurk];
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
													message:[error localizedDescription]
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
	[connection release];
	if(currentURL) {
		[currentURL release];
	}
	if(![self modalViewController]) {
		[super dealloc];
	}
}


@end
