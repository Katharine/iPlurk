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
#import "PlurkFormatting.h"

typedef enum {
	RootViewTabAll,
	RootViewTabMine,
	RootViewTabPrivate,
	RootViewTabReplied,
	RootViewTabNone = -1
} RootViewTab;

@interface UserTimelineTableViewController : UITableViewController <PlurkAPIDelegate, UIActionSheetDelegate> {
	IBOutlet SetupViewController *setupViewController;
	IBOutlet UISegmentedControl *tabs;
	NSMutableArray *masterPlurkArray;
	NSMutableArray *plurks;
	NSMutableArray *privatePlurks;
	NSMutableArray *unreadPlurks;
	NSMutableArray *myPlurks;
	NSMutableArray *repliedPlurks;
	NSMutableArray *currentPlurks;
	NSString *plurkTableCellType;
	RootViewTab currentTab;
	NSURLConnection *allRequest;
	NSURLConnection *privateRequest;
	NSURLConnection *unreadRequest;
	NSURLConnection *mineRequest;
	NSURLConnection *repliedRequest;
	NSInteger selectedRow;
	NSMutableDictionary *filesDownloading;
	Plurk *selectedPlurk;
	BOOL canUseTable;
	BOOL enableUserInterfacePaging;
	CGPoint contentOffset;
	NSInteger plurkToLoad;
	BOOL showSpringboardBadge;
	BOOL showingUnread;
}

@property(nonatomic, retain) IBOutlet SetupViewController *setupViewController;
@property(nonatomic, retain) IBOutlet UISegmentedControl *tabs;

- (IBAction)tabHasChanged;

- (void)userHasSetNewUsername:(NSString *)username andPassword:(NSString *)password;
- (void)toggleUnread;
- (void)startComposing;
- (void)startComposingWithContent:(NSString *)content qualifier:(NSString *)qualifier;
- (void)displayPlurkWithBase36ID:(NSString *)plurkID;
- (void)displayPlurkWithID:(NSInteger)plurkID;
- (void)displayPlurk:(Plurk *)plurk;
- (void)displayAlternateTimeline:(NSString *)timeline;
- (void)displayAlternateTimelineForFriend:(PlurkFriend *)friend;
- (NSUInteger)addNewPlurk:(Plurk *)plurk toPlurkArray:(NSMutableArray *)array usedForTab:(RootViewTab)tab;
- (void)respondedToPlurk:(Plurk *)plurk;

// PlurkAPIDelegate stuff.
- (void)plurkLoginDidFinish;
- (void)plurkLoginDidFail;
- (void)plurkHTTPRequestAborted:(NSError *)error;
- (void)connection:(NSURLConnection*)connection receivedNewPlurks:(NSArray *)plurks;
- (void)fileDownloadWithIdentifier:(NSNumber *)identifier completedWithData:(NSData *)data;
- (void)receivedPlurkResponsePoll:(NSArray *)newResponses;
@end
