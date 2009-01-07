//
//  iPlurkAppDelegate.m
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright AjaxLife Developments 2008. All rights reserved.
//

#import "iPlurkAppDelegate.h"
#import "UserTimelineTableViewController.h"


@implementation iPlurkAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
	BOOL handledURL = NO;
	
	if ([@"post" isEqualToString:[url host]]) {
		handledURL = YES;
		NSString *message = nil;
		NSString *qualifier = nil;
		
		NSArray *queryComponents = [[url query] componentsSeparatedByString:@"&"];
		NSString *queryComponent;
		for (queryComponent in queryComponents) {
			NSArray	*query = [queryComponent componentsSeparatedByString:@"="];
			if ([query count] == 2)	{
				NSString *queryKey = [query objectAtIndex:0];
				NSString *queryValue = [query objectAtIndex:1];
				NSString *decodedMessage = (NSString *)CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)queryValue, CFSTR(""));
				
				if ([@"message" isEqualToString:queryKey]) {
					message = decodedMessage;
				} else if ([@"qualifier" isEqualToString:queryKey]) {
					qualifier = decodedMessage;
				}
			}
		}
		//NSLog(@"Posting from URL: %@ %@", qualifier, message);
		UserTimelineTableViewController *controller = [[navigationController viewControllers] objectAtIndex:0];
		[controller startComposingWithContent:message qualifier:qualifier];
	} else if([@"view" isEqualToString:[url host]]) {
		handledURL = YES;
		NSInteger plurkID = [[[url path] substringFromIndex:1] integerValue];
		if(plurkID > 0) {
			UserTimelineTableViewController *controller = [[navigationController viewControllers] objectAtIndex:0];
			[controller displayPlurkWithID:plurkID];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't open plurk" message:@"A valid plurk was not specified." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if([@"p" isEqualToString:[url host]]) {
		NSString *plurkID = [[url path] substringFromIndex:1];
		UserTimelineTableViewController *controller = [[navigationController viewControllers] objectAtIndex:0];
		[controller displayPlurkWithBase36ID:plurkID];
	} else if([@"user" isEqualToString:[url host]]) {
		NSString *user = [[url path] substringFromIndex:1];
		UserTimelineTableViewController *controller = [[navigationController viewControllers] objectAtIndex:0];
		[controller displayAlternateTimeline:user];
	}
	
	return handledURL;
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
