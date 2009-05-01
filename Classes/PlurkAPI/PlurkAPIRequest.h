//
//  PlurkAPIRequest.h
//  iPlurk
//
//  Created on 14/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	PlurkAPIActionLogin,
	PlurkAPIActionMakePlurk,
	PlurkAPIActionRequestAlerts,
	PlurkAPIActionRespondToFriendRequest,
	PlurkAPIActionBlockUser,
	PlurkAPIActionUnblockUser,
	PlurkAPIActionRequestBlockedUsers,
	PlurkAPIActionTogglePlurkMute,
	PlurkAPIActionDeletePlurk,
	PlurkAPIActionRequestPlurks,
	PlurkAPIActionRespondToPlurk,
	PlurkAPIActionRequestResponses,
	PlurkAPIActionEditPlurk,
	PlurkAPIActionRequestFriendsForNewPlurks,
	PlurkAPIActionGetUpdatableData,
	PlurkAPIActionDeletePlurkResponse
} PlurkAPIAction;

@protocol PlurkAPIDelegate;

@interface PlurkAPIRequest : NSObject {
	NSMutableData *data;
	id <PlurkAPIDelegate> delegate;
	PlurkAPIAction action;
	NSArray *storage;
	NSURLConnection *connection;
}

@property(nonatomic, retain) NSMutableData *data;
@property(nonatomic, assign) id <PlurkAPIDelegate> delegate;
@property(nonatomic) PlurkAPIAction action;
@property(nonatomic, retain) NSArray *storage;
@property(nonatomic, retain) NSURLConnection *connection;

@end
