//
//  WebViewManager.m
//  iPlurk
//
//  Created on 09/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "WebViewManager.h"



@implementation WebViewManager

@synthesize webViews;

+ (WebViewManager *)manager {
	static WebViewManager *manager;
	if(!manager) {
		manager = [[WebViewManager alloc] init];
	}
	return manager;
}

- (WebViewManager *)init {
	[super init];
	webViews = [[NSMutableArray alloc] init];
	return self;
}

- (void)setUpWebView:(UIWebView *)webView withText:(NSString *)text {
	for(NSInteger i = 0; i < [webViews count]; ++i) {
		WebViewWithText *desc = [webViews objectAtIndex:i];
		if([desc webView] == webView) {
			[webViews removeObjectAtIndex:i];
			NSLog(@"Removed old instance of webView from queue.");
			break;
		}
	}
	WebViewWithText *webViewWithText = [[WebViewWithText alloc] init];
	webViewWithText.webView = webView;
	webViewWithText.text = text;
	[webViews addObject:webViewWithText];
	//[webViews insertObject:webViewWithText atIndex:[webViews count]];
	webView.delegate = self;
	if([webViews count] == 1)
	{
		NSLog(@"Starting UIWebView: Nothing running yet.");
		[webView loadHTMLString:text baseURL:nil];
	}
	[webViewWithText release];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if(![webViews count])
	{
		NSLog(@"WARNING: Unexpected webViewDidFinishLoad without any UIWebViews loading!");
		return;
	}
	[webViews removeObjectAtIndex:0];
	if([webViews count] > 0)
	{
		WebViewWithText *nextView = [webViews objectAtIndex:0];
		[[nextView webView] loadHTMLString:[nextView text] baseURL:nil];
	}
		
}

- (void)dealloc {
	[webViews dealloc];
	[super dealloc];
}

@end

@implementation WebViewWithText

@synthesize webView;
@synthesize text;

- (void)dealloc {
	[webView release];
	[text release];
	[super dealloc];
}

@end