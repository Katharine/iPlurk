//
//  PlurkAPI.m
//  iPlurk
//
//  Created on 09/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkAPI.h"

@implementation PlurkAPI
@synthesize userID, userName, friendDictionary, uidToName, loggedIn, currentUser;

+ (PlurkAPI *)sharedAPI {
	static PlurkAPI* shared;
	if(shared == nil) {
		shared = [[PlurkAPI alloc] init];
	}
	return shared;
}

- (PlurkAPI *)init {
	if(self = [super init]) {
		friendDictionary = [[NSMutableDictionary alloc] init];
		uidToName = [[NSMutableDictionary alloc] init];
		connections = [[MutableURLConnectionDictionary alloc] init];
		NSString *urlFile = [[NSBundle mainBundle] pathForResource:@"PlurkURLs" ofType:@"plist"];
		if(!urlFile)
		{
			NSLog(@"ERROR: Failed to locate PlurkURL plist!");
		}
		plurkURLs = [[NSDictionary alloc] initWithContentsOfFile: urlFile];
		NSLog(@"Loaded %d url(s) from PlurkURLs plist.", [plurkURLs count]);
		knownResponses = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSString *)escapeURL:(NSString *)url {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR("?=&+\\;"), kCFStringEncodingUTF8);
	return result;
}

#pragma mark Quick requests

- (NSString *)nickNameFromUserID:(NSInteger)userToFind {
	NSString *name = [uidToName objectForKey:[NSNumber numberWithInteger:userToFind]];
	if(![name length]) return [NSString stringWithFormat:@"User %d", userToFind, nil];
	return name;
}

- (NSInteger)userIDFromNickName:(NSString *)nickname {
	PlurkFriend *friend = [friendDictionary objectForKey:nickname];
	if(!friend) return -1;
	return [friend uid];
}

- (NSInteger)runningRequests {
	return [connections count];
}

#pragma mark HTTP communication

- (NSURLConnection *)makePostRequestTo:(NSURL *)url withPostData:(NSDictionary *)postData withAPIRequest:(PlurkAPIRequest *)apiRequest {
	NSMutableArray *queryBuilder = [[NSMutableArray alloc] init];
	if(postData && [postData count]) {
		NSArray *keys = [postData allKeys];
		for(NSString *key in keys) {
			NSString *value = [postData objectForKey:key];
			[queryBuilder addObject:[NSString stringWithFormat:@"%@=%@", key, [self escapeURL:value], nil]];
		}
	}
	NSURLConnection *connection = [self makeRawPostRequestTo:url withData:[queryBuilder componentsJoinedByString:@"&"] withAPIRequest:apiRequest];
	[queryBuilder release];
	return connection;
}

- (NSURLConnection *)makeRawPostRequestTo:(NSURL *)url withData:(NSString *)data withAPIRequest:(PlurkAPIRequest *)apiRequest {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"Making request to %@ with data %@", [url path], data);
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(!connection) {
		NSLog(@"HTTP POST request to %@ could not be initialised.");
		return nil;
	}
	if(apiRequest != nil) {
		[connections setObject:apiRequest forKey:connection];
		[apiRequest release];
	}
	[request release];
	return connection;
}

#pragma mark Login information

- (NSURLConnection *)loginUser:(NSString *)name withPassword:(NSString *)password delegate:(id <PlurkAPIDelegate>)delegate {
	userName = [name retain];
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setDelegate:delegate];
	[request setAction:PlurkAPIActionLogin];
	NSURL *loginURL = [NSURL URLWithString:[plurkURLs objectForKey:@"login"]];
	NSLog(@"Beginning login request.");
	return [self makePostRequestTo:loginURL withPostData:[NSDictionary dictionaryWithObjectsAndKeys:name, @"nick_name", password, @"password", nil] withAPIRequest:request];
}

- (BOOL)saveLoginToFile:(NSString *)path {
	NSMutableDictionary *save = [[NSMutableDictionary alloc] init];
	[save setObject:[NSNumber numberWithInteger:userID] forKey:@"userID"];
	[save setObject:userName forKey:@"userName"];
	[save setObject:[currentUser displayName] forKey:@"displayName"];
	[save setObject:[NSNumber numberWithBool:[currentUser hasProfileImage]] forKey:@"hasProfileImage"];
	NSLog(@"Saving ret to %@", path);
	BOOL ret = [save writeToFile:path atomically:NO];
	if(ret) {
		NSLog(@"Success.");
	} else {
		NSLog(@"Failed.");
	}
	[save release];
	return ret;
}

- (BOOL)quickLoginAs:(NSString *)username withFile:(NSString *)path {
	if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSLog(@"QuickLogin file does not exist.");
		return NO;
	}
	if([[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] fileModificationDate] timeIntervalSinceNow] > 604800) { // One week old data fails.
		NSLog(@"Ignoring old login data.");
		return NO;
	}
	NSDictionary *load = [NSDictionary dictionaryWithContentsOfFile:path];
	if(load == nil) {
		NSLog(@"Load failed.");
		return NO;
	}
	if(![[[load objectForKey:@"userName"] lowercaseString] isEqualToString:[username lowercaseString]]) {
		NSLog(@"Wrong userName");
		return NO;
	}
	userID = [[load objectForKey:@"userID"] integerValue];
	userName = [[load objectForKey:@"userName"] retain];
	currentUser = [[[PlurkFriend alloc] init] retain];
	currentUser.displayName = [load objectForKey:@"displayName"];
	currentUser.hasProfileImage = [[load objectForKey:@"hasProfileImage"] boolValue];
	loggedIn = YES;
	return YES;
}

#pragma mark Making requests

- (NSURLConnection *)requestPlurksWithDelegate:(id <PlurkAPIDelegate>)delegate {
	return [self requestPlurksFrom:-1 startingFrom:nil endingAt:nil onlyPrivate:NO delegate:delegate];
}

- (NSURLConnection *)requestPlurksStartingFrom:(NSDate *)startDate endingAt:(NSDate *)endDate onlyPrivate:(BOOL)onlyPrivate delegate:(id <PlurkAPIDelegate>)delegate {
	return [self requestPlurksFrom:-1 startingFrom:startDate endingAt:endDate onlyPrivate:onlyPrivate delegate:delegate];
}

- (NSURLConnection *)requestPlurksFrom:(NSInteger)user startingFrom:(NSDate *)startDate endingAt:(NSDate *)endDate onlyPrivate:(BOOL)onlyPrivate delegate:(id <PlurkAPIDelegate>)delegate {
	if(user < 0) user = userID;
	NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObject:[[NSString stringWithFormat:@"%d", user, nil] autorelease] forKey:@"user_id"];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"\"yyyy-MM-dd'T'HH:mm:ss\""];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	if(endDate != nil) {
		[query setObject:[formatter stringFromDate:endDate] forKey:@"from_date"];
	}
	if(startDate != nil) {
		[query setObject:[formatter stringFromDate:startDate] forKey:@"offset"];
	}
	[formatter release];
	if(onlyPrivate) {
		[query setObject:@"1" forKey:@"only_private"];
	}
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setDelegate:delegate];
	[request setAction:PlurkAPIActionRequestPlurks];
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_get"]];
	return [self makePostRequestTo:url withPostData:query withAPIRequest:request];
}

- (NSURLConnection *)requestResponsesToPlurk:(NSInteger)plurkID delegate:(id <PlurkAPIDelegate>)delegate {
	NSDictionary *query = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", plurkID, nil] forKey:@"plurk_id"];
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_get_responses"]];
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setDelegate:delegate];
	[request setAction:PlurkAPIActionRequestResponses];
	return [self makePostRequestTo:url withPostData:query withAPIRequest:request];
}

- (NSURLConnection *)requestUnreadPlurksWithDelegate:(id <PlurkAPIDelegate>)delegate {
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_get_unread"]];
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setDelegate:delegate];
	[request setAction:PlurkAPIActionRequestPlurks];
	return [self makePostRequestTo:url withPostData:nil withAPIRequest:request];
}

- (NSURLConnection *)requestPlurksByIDs:(NSArray *)ids delegate:(id <PlurkAPIDelegate>)delegate {
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_get_ids"]];
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setDelegate:delegate];
	[request setAction:PlurkAPIActionRequestPlurks];
	NSDictionary *post = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"[%@]", [ids componentsJoinedByString:@","], nil] forKey:@"ids"];
	return [self makePostRequestTo:url withPostData:post withAPIRequest:request];
}

- (NSURLConnection *)respondToPlurk:(NSInteger)plurk withQualifier:(NSString *)qualifier content:(NSString *)content delegate:(id <PlurkAPIDelegate>)delegate {
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_respond"]];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"\"yyyy-MM-dd'T'HH:mm:ss\""];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString *posted = [formatter stringFromDate:[NSDate date]];
	[formatter release];
	NSString *uidString = [[NSNumber numberWithInteger:userID] stringValue];
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys: posted, @"posted",
																	  qualifier, @"qualifier",
																	  content, @"content",
																	  @"en", @"lang",
																	  uidString, @"p_uid",
																	  uidString, @"uid",
																	  [[NSNumber numberWithInteger:plurk] stringValue], @"plurk_id",
																	  nil
	];
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setDelegate:delegate];
	[request setAction:PlurkAPIActionRespondToPlurk];
	return [self makePostRequestTo:url withPostData:query withAPIRequest:request];
}

- (NSURLConnection *)deletePlurk:(NSInteger)plurkID {
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setAction:PlurkAPIActionDeletePlurk];
	
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_delete"]];
	
	return [self makePostRequestTo:url withPostData:[NSDictionary dictionaryWithObject:[[NSNumber numberWithInteger:plurkID] stringValue] forKey:@"plurk_id"] withAPIRequest:request];
}

- (NSURLConnection *)editPlurk:(NSInteger)plurkID setText:(NSString *)text delegate:(id <PlurkAPIDelegate>)delegate {
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setAction:PlurkAPIActionEditPlurk];
	[request setDelegate:delegate];
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:text, @"content_raw", [[NSNumber numberWithInteger:plurkID] stringValue], @"plurk_id", nil];
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_edit"]];
	return [self makePostRequestTo:url withPostData:query withAPIRequest:request];
}

- (NSURLConnection *)makePlurk:(NSString *)text withQualifier:(NSString *)qualifier allowComments:(BOOL)comments limitedTo:(NSArray *)limited delegate:(id <PlurkAPIDelegate>)delegate {
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_add"]];
	NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
	[query setObject:[[NSNumber numberWithInteger:userID] stringValue] forKey:@"uid"];
	[query setObject:qualifier forKey:@"qualifier"];
	[query setObject:text forKey:@"content"];
	[query setObject:@"en" forKey:@"lang"];
	[query setObject:(comments ? @"0" : @"1") forKey:@"no_comments"];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"\"yyyy-MM-dd'T'HH:mm:ss\""];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString *posted = [formatter stringFromDate:[NSDate date]];
	[formatter release];
	[query setObject:posted forKey:@"posted"];
	
	if(limited) {
		[query setObject:[NSString stringWithFormat:@"[%@]", [limited componentsJoinedByString:@","], nil] forKey:@"limited_to"];
	}
	
	PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
	[request setDelegate:delegate];
	[request setAction:PlurkAPIActionMakePlurk];
	return [self makePostRequestTo:url withPostData:query withAPIRequest:request];
}

- (NSURLConnection *)makePlurk:(NSString *)text withQualifier:(NSString *)qualifier allowComments:(BOOL)comments delegate:(id <PlurkAPIDelegate>)delegate {
	return [self makePlurk:text withQualifier:qualifier allowComments:comments limitedTo:nil delegate:delegate];
}

- (void)markPlurksAsRead:(NSArray *)plurks {
	NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"plurk_mark_read"]];
	NSDictionary *post = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"[%@]", [plurks componentsJoinedByString:@","]] forKey:@"ids"];
	[self makePostRequestTo:url withPostData:post withAPIRequest:nil];
}

- (void)runPeriodicPollWithInterval:(NSTimeInterval)interval delegate:(id <PlurkAPIDelegate>)delegate {
	pollDelegate = delegate;
	if(pollTimer) {
		[pollTimer invalidate];
		[pollTimer release];
		pollTimer = nil;
	}
	pollTimer = [[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(runPoll:) userInfo:nil repeats:YES] retain];
	//[self runPoll:pollTimer];
}

- (void)cancelConnection:(NSURLConnection *)connection {
	NSLog(@"Cancelling connection.");
	[connection cancel];
	[connections removeObjectForKey:connection];
}

// NSTimer poll callback
- (void)runPoll:(NSTimer *)timer {
	NSLog(@"Running poll.");
	if(!pollNewConnection) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"\"yyyy-MM-dd'T'HH:mm:ss\""];
		[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		NSURL *pollURL = [NSURL URLWithString:[NSString stringWithFormat:[plurkURLs objectForKey:@"plurk_poll"], userID, [formatter stringFromDate:lastPlurkDate]]];
		[formatter release];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:pollURL];
		pollNewConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[connections setObject:[[PlurkAPIRequest alloc] init] forKey:pollNewConnection];
		[request release];
	}
	
	if(!pollResponsesConnection) {
		NSURL *pollURL = [NSURL URLWithString:[NSString stringWithFormat:[plurkURLs objectForKey:@"plurk_response_poll"], userID]];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:pollURL];
		pollResponsesConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[connections setObject:[[PlurkAPIRequest alloc] init] forKey:pollResponsesConnection];
		[request release];
	}
	
}

#pragma mark NSURLConnection callbacks

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	PlurkAPIRequest *request = [connections objectForKey:connection];
	if(!request) {
		[connection cancel];
		return;
	}
	[[request data] setLength:0];
};

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	PlurkAPIRequest *request = [connections objectForKey:connection];
	if(request) {
		[[request data] appendData:data];
	} else {
		[connection cancel];
	}
	if([request action] == PlurkAPIActionLogin) {
		NSString *body = [[NSString alloc] initWithData:[request data] encoding:NSUTF8StringEncoding];
		if([body rangeOfRegex:@"(?m)<script type=\"text/javascript\">(\r|\n|.)*?</script>"].location != NSNotFound) {
			NSLog(@"Got enough of the login page (%d bytes). Aborting and moving on with processing.", [data length]);
			[connection cancel];
			[self connectionDidFinishLoading:connection];
		}
		[body release];
	}
	//[data release];
};

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error %d loading data from URL: %@", [error code], [error description]);
	PlurkAPIRequest *request = [connections objectForKey:connection];
	if(request) {
		if([(NSObject *)[request delegate] respondsToSelector:@selector(plurkHTTPRequestAborted:)]) {
			[[request delegate] plurkHTTPRequestAborted:error];
		}
		[connections removeObjectForKey:connection];
	}
	[connection release];
	connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	PlurkAPIRequest *request = [[connections objectForKey:connection] retain];
	if(!request) return;
	[connections removeObjectForKey:connection];
	NSString *response = [[NSString alloc] initWithData:[request data] encoding:NSUTF8StringEncoding];
	if(connection == pollNewConnection) {
		NSLog(@"Handling pollNewConnection response.");
		[self handlePlurksReceived:response fromConnection:nil delegate:pollDelegate];
		[pollNewConnection release];
		pollNewConnection = nil;
	} else if(connection == pollResponsesConnection) {
		NSLog(@"Handling pollResponsesConnection response.");
		[self handleResponsePollReceived:response delegate:pollDelegate];
		[pollResponsesConnection release];
		pollResponsesConnection = nil;
	} else {
		switch ([request action]) {
			case PlurkAPIActionLogin: {
				[self handleLoginResponse:response delegate:[request delegate]];
				break;
			}
			case PlurkAPIActionRequestPlurks:
				[self handlePlurksReceived:response fromConnection:connection delegate:[request delegate]];
				break;
			case PlurkAPIActionRequestResponses:
				[self handleResponsesReceived:response delegate:[request delegate]];
				break;
			case PlurkAPIActionRespondToPlurk:
				[self handleResponseMade:response delegate:[request delegate]];
				break;
			case PlurkAPIActionMakePlurk:
				[self handlePlurkMade:response fromConnection:connection delegate:[request delegate]];
			case PlurkAPIActionEditPlurk:
				[self handlePlurksReceived:[NSString stringWithFormat:@"[%@]", response, nil] fromConnection:connection delegate:[request delegate]];
				break;
			case PlurkAPIActionRequestFriendsForNewPlurks:
				[self handleFriendsReceived:response forPlurks:[request storage] fromConnection:[request connection] delegate:[request delegate]];
				break;
			default:
				NSLog(@"Received unhandled action type in connectionDidFinishLoading!");
		}
	}
	[request release];
	[response release];
}

#pragma mark Internal callbacks

- (void)handleLoginResponse:(NSString *)response delegate:(id <PlurkAPIDelegate>)delegate {
	NSLog(@"Got plurkcookie!");
	NSRange uidRange = [response rangeOfRegex:@"\"user_id\": (\\d+)" capture:1];
	if(uidRange.location == NSNotFound) {
		NSLog(@"Could not find user's uid. Aborting login :(");
		[delegate plurkLoginDidFail];
		return;
	}
	NSString *uidString = [response substringWithRange:uidRange];
	userID = [uidString integerValue];
	if(userID <= 0) {
		NSLog(@"Failed to find a *valid* uid.");
		[delegate plurkLoginDidFail];
		return;
	}
	NSLog(@"Found uid %d for user.", userID);
	
	// Try and get out the friends.
	NSRange friendsRange = [response rangeOfRegex:@"var FRIENDS = (\\{.+\\});" capture:1];
	if(friendsRange.location == NSNotFound) {
		NSLog(@"Couldn't look up user's friends. Aborting.");
		[delegate plurkLoginDidFail];
		return;
	}
	NSDictionary *friends = [[response substringWithRange:friendsRange] JSONValue];
	if(friends == nil) {
		NSLog(@"Error parsing friends. :(");
		[delegate plurkLoginDidFail];
		return;
	}
	NSEnumerator *enumerator = [friends objectEnumerator];
	NSDictionary *friendDict;
	while((friendDict = [enumerator nextObject])) {
		PlurkFriend *friend = [[PlurkFriend alloc] init];
		friend.nickName = [friendDict objectForKey:@"nick_name"];
		friend.displayName = [friendDict objectForKey:@"display_name"];
		if([friend displayName] == (NSString *)[NSNull null] || [[friend displayName] length] == 0) {
			friend.displayName = [friend nickName];
		}
		friend.uid = [(NSNumber *)[friendDict objectForKey:@"uid"] integerValue] ;
		friend.hasProfileImage = [(NSNumber *)[friendDict objectForKey:@"has_profile_image"] boolValue];
		friend.relationship = [[[friendDict objectForKey:@"relationship"] capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
		friend.karma = [(NSNumber *)[friendDict objectForKey:@"karma"] floatValue];
		friend.fullName = [friendDict objectForKey:@"full_name"];
		friend.gender = (PlurkGender)[(NSNumber *)[friendDict objectForKey:@"gender"] integerValue];
		friend.pageTitle = [friendDict objectForKey:@"page_title"];
		friend.location = [friendDict objectForKey:@"location"];
		[friendDictionary setObject:friend forKey:friend.nickName];
		[uidToName setObject:friend.nickName forKey:[NSNumber numberWithInteger:friend.uid]];
	}
	
	// Add ourselves to the friend list.
	NSRange globalRange = [response rangeOfRegex:@"var GLOBAL = (.+)" capture:1];
	if(globalRange.location == NSNotFound) {
		NSLog(@"Couldn't look up global range. Aborting.");
		[delegate plurkLoginDidFail];
		return;
	}
	NSString *globalStr =  [[response substringWithRange:globalRange] stringByReplacingOccurrencesOfRegex:@"new Date\\((.*?)\\)" withString:@"$1"];
	NSDictionary *global = [globalStr JSONValue];
	if(global == nil) {
		NSLog(@"Couldn't parse global range. Aborting.");
		NSLog(@"%@", [response substringWithRange:globalRange]);
		[delegate plurkLoginDidFail];
		return;
	}
	
	NSDictionary *pageUser = [global objectForKey:@"page_user"];
	PlurkFriend *friend = [[PlurkFriend alloc] init];
	friend.nickName = [pageUser objectForKey:@"nick_name"];
	friend.displayName = [pageUser objectForKey:@"display_name"];
	if([friend displayName] == (NSString *)[NSNull null]) {
		friend.displayName = [friend nickName];
	}
	friend.uid = userID;
	// Logged in as the wrong person - oops.
	if(![[userName lowercaseString] isEqualToString:[[friend nickName] lowercaseString]]) {
		NSLog(@"Names don't match!");
		[delegate plurkLoginDidFail];
		return;
	}
	userName = [friend nickName]; // Update our own username for capitalisation.
	friend.hasProfileImage = [(NSNumber *)[pageUser objectForKey:@"has_profile_image"] boolValue];
	friend.relationship = [[[pageUser objectForKey:@"relationship"] capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
	friend.karma = [(NSNumber *)[pageUser objectForKey:@"karma"] floatValue];
	friend.fullName = [pageUser objectForKey:@"full_name"];
	friend.gender = (PlurkGender)[(NSNumber *)[friendDict objectForKey:@"gender"] integerValue];
	friend.pageTitle = [pageUser objectForKey:@"page_title"];
	friend.location = [pageUser objectForKey:@"location"];
	[friendDictionary setObject:friend forKey:userName];
	[uidToName setObject:userName forKey:[NSNumber numberWithInteger:userID]];
	currentUser = [friend retain];
	NSLog(@"Login successful.");
	loggedIn = YES;
	[delegate plurkLoginDidFinish];
}

- (void)handlePlurksReceived:(NSString *)responseString fromConnection:(NSURLConnection *)connection delegate:(id <PlurkAPIDelegate>)delegate {
	NSLog(@"Received plurks. %@", responseString);
	responseString = [responseString stringByReplacingOccurrencesOfRegex:@"new Date\\((.*?)\\)" withString:@"$1"];
	NSArray *response = [responseString JSONValue];
	if(response == nil) {
		NSLog(@"Failed to parse JSON for new plurks.");
		NSLog(@"%@", responseString);
		return;
	}
	NSMutableArray *plurks = [[NSMutableArray alloc] init];
	NSMutableArray *friendsToLookUp = [[NSMutableArray alloc] init];
	for(NSDictionary *plurkDict in response) {
		Plurk *plurk = [[Plurk alloc] init];
		plurk.lang = [plurkDict objectForKey:@"lang"];
		plurk.contentRaw = [plurkDict objectForKey:@"content_raw"];
		plurk.userID = [(NSNumber *)[plurkDict objectForKey:@"user_id"] integerValue];
		plurk.plurkType = [(NSNumber *)[plurkDict objectForKey:@"plurk_type"] integerValue];
		plurk.plurkID = [(NSNumber *)[plurkDict objectForKey:@"plurk_id"] integerValue];
		plurk.responseCount = [(NSNumber *)[plurkDict objectForKey:@"response_count"] integerValue];
		plurk.responsesSeen = [(NSNumber *)[plurkDict objectForKey:@"responses_seen"] integerValue];
		if([plurk responsesSeen] > [plurk responseCount]) plurk.responsesSeen = [plurk responseCount]; // Sometimes Plurk claims we've seen more responses than there are.
		plurk.ownerID = [(NSNumber *)[plurkDict objectForKey:@"owner_id"] integerValue];
		plurk.qualifier = [plurkDict objectForKey:@"qualifier"];
		plurk.content = [plurkDict objectForKey:@"content"];
		plurk.posted = [NSDate dateWithNaturalLanguageString:[plurkDict objectForKey:@"posted"]];
		if([plurk posted] == nil) {
			plurk.posted = [NSDate date];
		}
		NSString *limitedToString = [plurkDict objectForKey:@"limited_to"];
		if((NSString *)[NSNull null] != limitedToString) {
			NSArray *limitedToStringArray = [[limitedToString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|"]] componentsSeparatedByString:@"||"];
			NSMutableArray *limitedTo = [[NSMutableArray alloc] init];
			for(NSString *limit in limitedToStringArray) {
				[limitedTo addObject:[NSNumber numberWithInteger:[limit integerValue]]];
			}
			plurk.limitedTo = [NSArray arrayWithArray:limitedTo];
			[limitedTo release];
		} else {
			plurk.limitedTo = [[NSArray alloc] init];
		}
		plurk.noComments = [(NSNumber *)[plurkDict objectForKey:@"no_comments"] boolValue];
		plurk.isUnread = [(NSNumber *)[plurkDict objectForKey:@"is_unread"] integerValue];
		plurk.ownerDisplayName = [[friendDictionary objectForKey:[self nickNameFromUserID:[plurk ownerID]]] displayName];
		if(!plurk.ownerDisplayName) {
			[friendsToLookUp addObject:[NSNumber numberWithInteger:[plurk ownerID]]];
		}
		plurk.ownerNickName = [self nickNameFromUserID:[plurk ownerID]];
		
		if(lastPlurkDate == nil || [[plurk posted] compare:lastPlurkDate] == NSOrderedDescending) {
			[lastPlurkDate release];
			lastPlurkDate = [[plurk posted] copy];
			[lastPlurkDate retain];
		}
		if(lastPlurkDate == nil) lastPlurkDate = [[[plurk posted] copy] retain];
		
		[plurks addObject:plurk];
		[plurk release];
	}
	if([friendsToLookUp count] > 0) {
		NSDictionary *post = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"[%@]", [friendsToLookUp componentsJoinedByString:@","]] forKey:@"ids"];
		NSURL *url = [NSURL URLWithString:[plurkURLs objectForKey:@"fetch_friends"]];
		PlurkAPIRequest *request = [[PlurkAPIRequest alloc] init];
		[request setDelegate:delegate];
		[request setAction:PlurkAPIActionRequestFriendsForNewPlurks];
		[request setStorage:plurks];
		[request setConnection:connection];
		[self makePostRequestTo:url withPostData:post withAPIRequest:request];
	} else {
		[delegate connection:connection receivedNewPlurks:plurks];
		[plurks release];
	}
}

- (void)handleResponsesReceived:(NSString *)responseString delegate:(id <PlurkAPIDelegate>)delegate {
	NSDictionary *responseDict = [[responseString stringByReplacingOccurrencesOfRegex:@"new Date\\((.*?)\\)" withString:@"$1"] JSONValue];
	NSDictionary *responders = [responseDict objectForKey:@"friends"];
	NSArray *responsesRaw = [responseDict objectForKey:@"responses"];
	NSMutableArray *responses = [[NSMutableArray alloc] init];
	NSMutableDictionary *friends = [[NSMutableDictionary alloc] init];
	for(NSDictionary *responseRaw in responsesRaw) {
		ResponsePlurk *response = [[ResponsePlurk alloc] init];
		response.userID = [(NSNumber *)[responseRaw objectForKey:@"user_id"] integerValue];
		response.qualifier = [responseRaw objectForKey:@"qualifier"];
		response.content = [responseRaw objectForKey:@"content"];
		response.contentRaw = [responseRaw objectForKey:@"content_raw"];
		response.posted = [NSDate dateWithNaturalLanguageString:[responseRaw objectForKey:@"posted"]];
		
		NSDictionary *responder = [responders objectForKey:[[NSNumber numberWithInteger:response.userID] stringValue]];
		response.userHasDisplayPicture = [(NSNumber *)[responder objectForKey:@"has_profile_image"] boolValue];
		response.userDisplayName = [responder objectForKey:@"display_name"];
		if([response userDisplayName] == (NSString *)[NSNull null] || [[response userDisplayName] length] == 0) {
			response.userDisplayName = [responder objectForKey:@"nick_name"];
		}
		response.userNickName = [responder objectForKey:@"nick_name"];
		// Add to the temporary friend list if it's not already there.
		if(![friends objectForKey:[responder objectForKey:@"nick_name"]]) {
			[friends setObject:[response userDisplayName] forKey:[responder objectForKey:@"nick_name"]];
		}
		[responses addObject:response];
	}
	[delegate receivedPlurkResponses:responses withResponders:friends];
	[responses release];
}

- (void)handleResponsePollReceived:(NSString *)responseString delegate:(id <PlurkAPIDelegate>)delegate {
	NSLog(@"Received response poll");
	NSArray *plurksWithResponses = [NSMutableArray arrayWithArray:[[responseString stringByReplacingOccurrencesOfRegex:@"new Date\\((.*?)\\)" withString:@"$1"] JSONValue]];
	NSMutableArray *newPlurks = [[NSMutableArray alloc] init];
	for(NSDictionary *dict in plurksWithResponses) {
		NSMutableDictionary *oldResponse;
		if((oldResponse = [knownResponses objectForKey:[dict objectForKey:@"plurk_id"]])) {
			if([[oldResponse objectForKey:@"response_count"] integerValue] != [[dict objectForKey:@"response_count"] integerValue]) {
				[oldResponse setObject:[[dict objectForKey:@"response_count"] copy] forKey:@"response_count"];
				[newPlurks addObject:dict];
			}
			continue;
		}
		[knownResponses setObject:[NSMutableDictionary dictionaryWithDictionary:dict] forKey:[dict objectForKey:@"plurk_id"]];
		[newPlurks addObject:dict];
	}
	if([newPlurks count] > 0) {
		[delegate receivedPlurkResponsePoll:newPlurks];
	}
	[newPlurks release];
	
}

- (void)handleFriendsReceived:(NSString *)response forPlurks:(NSArray *)plurks fromConnection:(NSURLConnection *)connection delegate:(id <PlurkAPIDelegate>)delegate {
	NSDictionary *newFriends = [[response stringByReplacingOccurrencesOfRegex:@"new Date\\((.*?)\\)" withString:@"$1"] JSONValue];
	NSEnumerator *enumerator = [newFriends objectEnumerator];
	NSDictionary *friend;
	while((friend = [enumerator nextObject])) {
		PlurkFriend *newFriend = [[PlurkFriend alloc] init];
		newFriend.displayName = [friend objectForKey:@"display_name"];
		newFriend.nickName = [friend objectForKey:@"nick_name"];
		if((NSNull *)[newFriend displayName] == [NSNull null] || [[newFriend displayName] length] == 0) {
			newFriend.displayName = newFriend.nickName;
		}
		newFriend.uid = [[friend objectForKey:@"uid"] integerValue];
		newFriend.gender = (PlurkGender)[[friend objectForKey:@"gender"] integerValue];
		newFriend.hasProfileImage = [[friend objectForKey:@"has_profile_image"] boolValue];
		[friendDictionary setObject:newFriend forKey:[newFriend nickName]];
		[uidToName setObject:[newFriend nickName] forKey:[NSNumber numberWithInteger:[newFriend uid]]];
		for(Plurk *plurk in plurks) {
			if([plurk ownerID] == [newFriend uid]) {
				plurk.ownerDisplayName = [newFriend displayName];
				plurk.ownerNickName = [newFriend nickName];
			}
		}
	}
	[delegate connection:connection receivedNewPlurks:plurks];
}

- (void)handleResponseMade:(NSString *)responseString delegate:(id <PlurkAPIDelegate>)delegate {
	NSLog(@"Response made: %@", responseString);
	NSDictionary *responseRaw = [[[responseString stringByReplacingOccurrencesOfRegex:@"new Date\\((.*?)\\)" withString:@"$1"] JSONValue] objectForKey:@"object"];
	if(responseRaw == nil) {
		NSLog(@"Unable to parse response!");
		return;
	}
	ResponsePlurk *response = [[[ResponsePlurk alloc] init] autorelease];
	response.userID = [(NSNumber *)[responseRaw objectForKey:@"user_id"] integerValue];
	response.plurkID = [(NSNumber *)[responseRaw objectForKey:@"plurk_id"] integerValue];
	response.qualifier = [responseRaw objectForKey:@"qualifier"];
	response.content = [responseRaw objectForKey:@"content"];
	response.contentRaw = [responseRaw objectForKey:@"content_raw"];
	response.posted = [NSDate dateWithNaturalLanguageString:[responseRaw objectForKey:@"posted"]];
	response.userHasDisplayPicture = [currentUser hasProfileImage];
	response.userDisplayName = [currentUser displayName];
	[delegate plurkResponseCompleted:response];
}

- (void)handlePlurkMade:(NSString *)response fromConnection:(NSURLConnection *)connection delegate:(id <PlurkAPIDelegate>)delegate {
	NSDictionary *plurk = [[[response stringByReplacingOccurrencesOfRegex:@"new Date\\((.*?)\\)" withString:@"$1"] JSONValue] objectForKey:@"plurk"];
	[self handlePlurksReceived:[[NSArray arrayWithObject:plurk] JSONRepresentation] fromConnection:connection delegate:delegate];
}

#pragma mark NSObject

- (void)dealloc {
	[userName release];
	[friendDictionary release];
	[uidToName release];
	[currentUser release];
	[super dealloc];
}

@end
