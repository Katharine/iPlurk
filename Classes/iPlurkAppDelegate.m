//
//  iPlurkAppDelegate.m
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright AjaxLife Developments 2008. All rights reserved.
//

#import "iPlurkAppDelegate.h"
#import "RootViewController.h"


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
	
	if ([@"/post" isEqualToString:[url path]]) {
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
		NSLog(@"Posting from URL: %@ %@", qualifier, message);
		RootViewController *controller = [[navigationController viewControllers] objectAtIndex:0];
		[controller startComposingWithContent:message qualifier:qualifier];
		//[controller release];
	}
	
	return handledURL;
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
