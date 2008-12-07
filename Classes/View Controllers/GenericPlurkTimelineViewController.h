//
//  GenericPlurkTimelineViewController.h
//  iPlurk
//
//  Created by AjaxLife Developments on 07/12/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkAPI.h"
#import "PlurkTableViewCell.h"
#import "ProfileImageCache.h"
#import "FileDownloader.h"
#import "RootViewController.h"

@interface GenericPlurkTimelineViewController : UITableViewController <PlurkAPIDelegate, UITableViewDelegate> {
	PlurkFriend *timelineOwner;
	NSString *timelineToLoad;
	NSMutableArray *plurks;
	NSMutableArray *filesDownloading;
	NSMutableData *receivedData;
	NSURLConnection *connection;
}

@property(nonatomic, retain) PlurkFriend *timelineOwner;
@property(nonatomic, retain) NSString *timelineToLoad;

@end
