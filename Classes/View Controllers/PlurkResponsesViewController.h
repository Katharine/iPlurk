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

@interface PlurkResponsesViewController : UIViewController <PlurkAPIDelegate, UIWebViewDelegate, UIActionSheetDelegate> {
	Plurk *firstPlurk;
	IBOutlet UIWebView *webView;
	NSString *avatarPath;
	NSString *emoticonPath;
	PlurkAPI *plurkAPI;
	NSURL *currentURL;
	NSURLConnection *connection;
	id delegate;
}

@property(nonatomic, retain) Plurk *firstPlurk;
@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) NSString *avatarPath;
@property(nonatomic, retain) NSString *emoticonPath;
@property(nonatomic, retain) PlurkAPI *plurkAPI;
@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) NSURLConnection *connection;

- (void)beginReply;
- (NSString *)processPlurkContent:(NSString *)content;


@end
