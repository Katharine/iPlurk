//
//  ResponsePlurk.h
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ResponsePlurk : NSObject {
	NSString *userDisplayName;
	NSString *userNickName;
	NSInteger userID;
	NSString *qualifier;
	NSString *content;
	NSString *contentRaw;
	NSInteger plurkID;
	NSDate *posted;
	BOOL userHasDisplayPicture;
}

@property(nonatomic, retain) NSString *userDisplayName;
@property(nonatomic, retain) NSString *userNickName;
@property(nonatomic) NSInteger userID;
@property(nonatomic, retain) NSString *qualifier;
@property(nonatomic, retain) NSString *content;
@property(nonatomic, retain) NSString *contentRaw;
@property(nonatomic) NSInteger plurkID;
@property(nonatomic, retain) NSDate *posted;
@property(nonatomic) BOOL userHasDisplayPicture;

- (void)dealloc;

@end
