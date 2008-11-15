//
//  RootViewController.h
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright AjaxLife Developments 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewManager.h"
#import "PlurkAPI.h";
#import "SetupViewController.h"
#import "PlurkTableViewCell.h"
#import "LoadMorePlurksCell.h"
#import "iPlurkAppDelegate.h"
#import "FileDownloader.h"
#import "ProfileImageCache.h"
#import "PlurkResponsesViewController.h"
#import "Quartz.h"

typedef enum {
	RootViewTabAll,
	RootViewTabUnread,
	RootViewTabPrivate
} RootViewTab;

@interface RootViewController : UITableViewController <PlurkAPIDelegate> {
	IBOutlet SetupViewController *setupViewController;
	IBOutlet UISegmentedControl *tabs;
	NSMutableArray *plurks;
	NSMutableArray *privatePlurks;
	NSMutableArray *unreadPlurks;
	NSMutableArray *currentPlurks;
	PlurkAPI *plurkAPI;
	NSString *imageCacheDirectory;
	NSString *plurkTableCellType;
	RootViewTab currentTab;
	NSURLConnection *allRequest;
	NSURLConnection *privateRequest;
	NSURLConnection *unreadRequest;
	NSInteger selectedRow;
	Plurk *selectedPlurk;
	BOOL canUseTable;
}

@property(nonatomic, retain) NSMutableArray *plurks;
@property(nonatomic, retain) NSMutableArray *privatePlurks;
@property(nonatomic, retain) NSMutableArray *unreadPlurks;
@property(nonatomic, assign) NSMutableArray *currentPlurks;
@property(nonatomic, retain) PlurkAPI *plurkAPI;
@property(nonatomic, retain) IBOutlet SetupViewController *setupViewController;
@property(nonatomic, retain) IBOutlet UISegmentedControl *tabs;

- (IBAction)tabHasChanged;

- (void)userHasSetNewUsername:(NSString *)username andPassword:(NSString *)password;
- (void)startComposing;
- (void)startComposingWithContent:(NSString *)content qualifier:(NSString *)qualifier;

// PlurkAPIDelegate stuff.
- (void)plurkLoginDidFinish;
- (void)plurkLoginDidFail;
- (void)plurkHTTPRequestAborted:(NSError *)error;
- (void)connection:(NSURLConnection*)connection receivedNewPlurks:(NSArray *)plurks;
- (void)fileDownloadDidComplete:(NSString *)file;
- (void)receivedPlurkResponsePoll:(NSArray *)newResponses;
@end
