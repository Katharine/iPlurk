//
//  Plurk.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Plurk : NSObject {
	NSString *lang;
	NSString *contentRaw;
	NSInteger userID;
	NSInteger plurkType;
	NSInteger plurkID;
	NSInteger responseCount;
	NSInteger ownerID;
	NSString *qualifier;
	NSString *content;
	NSInteger responsesSeen;
	NSDate *posted;
	NSArray *limitedTo;
	BOOL noComments;
	NSInteger isUnread;
	NSString *ownerDisplayName;
}

@property(nonatomic, retain) NSString *lang;
@property(nonatomic, retain) NSString *contentRaw;
@property NSInteger userID;
@property NSInteger plurkType;
@property NSInteger plurkID;
@property NSInteger responseCount;
@property NSInteger ownerID;
@property(nonatomic, retain) NSString *qualifier;
@property(nonatomic, retain) NSString *content;
@property NSInteger responsesSeen;
@property(nonatomic, retain) NSDate *posted;
@property(nonatomic, retain) NSArray *limitedTo;
@property BOOL noComments;
@property NSInteger isUnread;
@property(nonatomic, retain) NSString *ownerDisplayName;

@end
