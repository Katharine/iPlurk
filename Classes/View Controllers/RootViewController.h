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
#import "GenericPlurkTimelineViewController.h"

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
	NSString *imageCacheDirectory;
	NSString *plurkTableCellType;
	RootViewTab currentTab;
	NSURLConnection *allRequest;
	NSURLConnection *privateRequest;
	NSURLConnection *unreadRequest;
	NSInteger selectedRow;
	NSMutableArray *filesDownloading;
	Plurk *selectedPlurk;
	BOOL canUseTable;
	BOOL enableUserInterfacePaging;
	CGPoint contentOffset;
	NSInteger plurkToLoad;
}

@property(nonatomic, retain) NSMutableArray *plurks;
@property(nonatomic, retain) NSMutableArray *privatePlurks;
@property(nonatomic, retain) NSMutableArray *unreadPlurks;
@property(nonatomic, assign) NSMutableArray *currentPlurks;
@property(nonatomic, retain) IBOutlet SetupViewController *setupViewController;
@property(nonatomic, retain) IBOutlet UISegmentedControl *tabs;

- (IBAction)tabHasChanged;

- (void)userHasSetNewUsername:(NSString *)username andPassword:(NSString *)password;
- (void)startComposing;
- (void)startComposingWithContent:(NSString *)content qualifier:(NSString *)qualifier;
- (void)displayPlurkWithBase36ID:(NSString *)plurkID;
- (void)displayPlurkWithID:(NSInteger)plurkID;
- (void)displayPlurk:(Plurk *)plurk;
- (void)displayAlternateTimeline:(NSString *)timeline;
- (void)displayAlternateTimelineForFriend:(PlurkFriend *)friend;

// PlurkAPIDelegate stuff.
- (void)plurkLoginDidFinish;
- (void)plurkLoginDidFail;
- (void)plurkHTTPRequestAborted:(NSError *)error;
- (void)connection:(NSURLConnection*)connection receivedNewPlurks:(NSArray *)plurks;
- (void)fileDownloadDidComplete:(NSString *)file;
- (void)receivedPlurkResponsePoll:(NSArray *)newResponses;
@end
