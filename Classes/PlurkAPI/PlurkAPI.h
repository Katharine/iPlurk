//
//  PlurkAPI.h
//  iPlurk
//
//  Created on 09/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSON/JSON.h>
#import "RegexKitLite.h"
#import "Plurk.h"
#import "PlurkFriend.h"
#import "PlurkAPIDelegate.h"
#import "ResponsePlurk.h"
#import "PlurkAPIRequest.h"
#import "MutableURLConnectionDictionary.h"

typedef enum {
	PlurkAlertAcceptFriendship,
	PlurkAlertRefuseFriendship,
	PlurkAlertMakeFan
} PlurkAlert;

@interface PlurkAPI : NSObject {
	BOOL loggedIn;
	NSInteger userID;
	NSString *userName;
	NSMutableDictionary *friendDictionary;
	NSMutableDictionary *uidToName;
	NSDictionary *plurkURLs;
	//PlurkAPIAction currentAction;
	//NSHTTPURLResponse *urlResponse;
	//NSHTTPCookie *plurkCookie;
	MutableURLConnectionDictionary *connections;
	NSURLConnection *pollNewConnection;
	NSURLConnection *pollResponsesConnection;
	id<PlurkAPIDelegate> pollDelegate;
	NSTimer *pollTimer;
	NSDate *lastPlurkDate;
	NSMutableDictionary *knownResponses;
	PlurkFriend *currentUser;
}

@property(readonly) BOOL loggedIn;
@property(readonly) NSInteger userID;
@property(nonatomic, readonly, retain) NSString *userName;
@property(nonatomic, retain) NSMutableDictionary *friendDictionary;
@property(nonatomic, retain) NSMutableDictionary *uidToName;
@property(nonatomic, readonly, retain) PlurkFriend *currentUser;

- (NSString *)escapeURL:(NSString *)url;
- (NSURLConnection *)makePostRequestTo:(NSURL *)url withPostData:(NSDictionary *)postData withAPIRequest:(PlurkAPIRequest *)request;
- (NSURLConnection *)makeRawPostRequestTo:(NSURL *)url withData:(NSString *)data withAPIRequest:(PlurkAPIRequest *)request;

- (NSString *)nickNameFromUserID:(NSInteger)userID;
- (NSInteger)userIDFromNickName:(NSString *)nickname;

- (PlurkAPI *)init;
- (void)cancelConnection:(NSURLConnection *)connection;
- (NSInteger)runningRequests;

- (NSURLConnection *)loginUser:(NSString *)name withPassword:(NSString *)password delegate:(id <PlurkAPIDelegate>)delegate;
- (BOOL)saveLoginToFile:(NSString *)path;
- (BOOL)quickLoginAs:(NSString *)username withFile:(NSString *)path;

- (NSURLConnection *)requestPlurksFrom:(NSInteger)user startingFrom:(NSDate *)startDate endingAt:(NSDate *)endDate onlyPrivate:(BOOL)onlyPrivate delegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)requestPlurksStartingFrom:(NSDate *)startDate endingAt:(NSDate *)endDate onlyPrivate:(BOOL)onlyPrivate delegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)requestPlurksWithDelegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)requestResponsesToPlurk:(NSInteger)plurkID delegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)requestUnreadPlurksWithDelegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)requestPlurksByIDs:(NSArray *)ids delegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)respondToPlurk:(NSInteger)plurk withQualifier:(NSString *)qualifier content:(NSString *)content delegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)deletePlurk:(NSInteger)plurkID;
- (NSURLConnection *)editPlurk:(NSInteger)plurkID setText:(NSString *)text delegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)makePlurk:(NSString *)text withQualifier:(NSString *)text allowComments:(BOOL)comments delegate:(id <PlurkAPIDelegate>)delegate;
- (NSURLConnection *)makePlurk:(NSString *)text withQualifier:(NSString *)text allowComments:(BOOL)comments limitedTo:(NSArray *)limited delegate:(id <PlurkAPIDelegate>)delegate;
- (void)runPeriodicPollWithInterval:(NSTimeInterval)interval delegate:(id <PlurkAPIDelegate>)delegate;

/*
- (void)makePlurk:(NSString *)text withQualifier:(NSString *)text allowComments:(BOOL)comments;
- (void)makePlurk:(NSString *)text withQualifier:(NSString *)text allowComments:(BOOL)comments limitedTo:(NSArray *)limited;
- (void)requestAlerts;
- (void)respondToFriendRequest:(NSInteger)requester withAction:(PlurkAlert)action;
- (void)blockUser:(NSInteger)user;
- (void)unblockUser:(NSInteger)user;
- (void)requestBlockedUsers;
- (void)togglePlurkMute:(NSInteger)plurkID setMuted:(BOOL)muted;
*/

// Internal callbacks
- (void)handleLoginResponse:(NSString *)response delegate:(id <PlurkAPIDelegate>)delegate;
- (void)handlePlurksReceived:(NSString *)response fromConnection:(NSURLConnection *)connection delegate:(id <PlurkAPIDelegate>)delegate;
- (void)handleResponsesReceived:(NSString *)responseString delegate:(id <PlurkAPIDelegate>)delegate;
- (void)handleResponsePollReceived:(NSString *)responseString delegate:(id <PlurkAPIDelegate>)delegate;
- (void)handleFriendsReceived:(NSString *)response forPlurks:(NSArray *)plurks fromConnection:(NSURLConnection *)connection delegate:(id <PlurkAPIDelegate>)delegate;
- (void)handlePlurkMade:(NSString *)response fromConnection:(NSURLConnection *)connection delegate:(id <PlurkAPIDelegate>)delegate;
- (void)runPoll:(NSTimer *)timer;

// NSURLConnection stuff.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end