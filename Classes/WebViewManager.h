//
//  WebViewManager.h
//  iPlurk
//
//  Created on 09/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewManager : NSObject <UIWebViewDelegate> {
	NSMutableArray *webViews;
}

- (void)setUpWebView:(UIWebView *)webView withText:(NSString *)text;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
+ (WebViewManager *)manager;

@property(nonatomic, retain) NSMutableArray *webViews;

@end

@interface WebViewWithText : NSObject {
	NSString *text;
	UIWebView *webView;
}

@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) UIWebView *webView;

@end

