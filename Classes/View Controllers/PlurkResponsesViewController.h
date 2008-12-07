//
//  PlurkResponsesViewController.h
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkAPI.h"
#import "WebPagePreviewController.h"
#import "WritePlurkTableViewController.h"
#import "PlurkEntryTableViewCell.h"

@class RootViewController;
@interface PlurkResponsesViewController : UIViewController <PlurkAPIDelegate, UIWebViewDelegate, UIActionSheetDelegate> {
	Plurk *firstPlurk;
	IBOutlet UIWebView *webView;
	NSString *avatarPath;
	NSString *emoticonPath;
	NSURL *currentURL;
	NSURLConnection *connection;
	id delegate;
	NSInteger plurkIDToLoad;
}

@property(nonatomic, retain) Plurk *firstPlurk;
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) NSString *avatarPath;
@property(nonatomic, retain) NSString *emoticonPath;
@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic) NSInteger plurkIDToLoad;

- (void)beginReply;
- (void)finishUISetup;
- (NSString *)processPlurkContent:(NSString *)content;


@end
