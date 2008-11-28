//
//  WebPagePreviewController.h
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebPagePreviewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {
	IBOutlet UIWebView *webView;
	
	NSURLRequest *requestToLoad;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;

@property(nonatomic, retain) NSURLRequest *requestToLoad;

- (void)closeView;
- (void)openSafari;

@end
