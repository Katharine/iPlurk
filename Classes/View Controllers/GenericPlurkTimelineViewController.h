//
//  GenericPlurkTimelineViewController.h
//  iPlurk
//
//  Created on 07/12/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkAPI.h"
#import "PlurkTableViewCell.h"
#import "ProfileImageCache.h"
#import "FileDownloader.h"
#import "RootViewController.h"
#import "PlurkFormatting.h"

@interface GenericPlurkTimelineViewController : UITableViewController <PlurkAPIDelegate, UITableViewDelegate> {
	PlurkFriend *timelineOwner;
	NSString *timelineToLoad;
	NSMutableArray *plurks;
	BOOL downloadStarted;
	NSMutableData *receivedData;
	NSURLConnection *connection;
	NSURLConnection *apiConnection;
}

@property(nonatomic, retain) PlurkFriend *timelineOwner;
@property(nonatomic, retain) NSString *timelineToLoad;

@end
