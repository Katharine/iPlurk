//
//  WebPagePreviewController.h
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebPagePreviewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {
	IBOutlet UIBarButtonItem *closeButton;
	IBOutlet UIBarButtonItem *safariButton;
	IBOutlet UIWebView *webView;
	
	NSURLRequest *requestToLoad;
}

@property(nonatomic, retain) IBOutlet UIBarButtonItem *closeButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *safariButton;
@property(nonatomic, retain) IBOutlet UIWebView *webView;

@property(nonatomic, retain) NSURLRequest *requestToLoad;

- (IBAction)closeView;
- (IBAction)openSafari;

@end
