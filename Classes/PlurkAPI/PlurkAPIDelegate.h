//
//  PlurkAPIDelegate.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#include "ResponsePlurk.h"

@protocol PlurkAPIDelegate 

@optional
- (void)plurkHTTPRequestAborted:(NSError *)error;
- (void)connection:(NSURLConnection *)connection receivedNewPlurks:(NSArray *)plurks;
- (void)plurkLoginDidFinish;
- (void)plurkLoginDidFail;
- (void)receivedPlurkResponses:(NSArray *)responses;
- (void)receivedPlurkResponsePoll:(NSArray *)plurksWithResponses;
- (void)plurkResponseCompleted:(ResponsePlurk *)response;

@end
