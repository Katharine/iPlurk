//
//  ResponsePlurk.m
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "ResponsePlurk.h"


@implementation ResponsePlurk
@synthesize userDisplayName, userID, qualifier, content, contentRaw, plurkID, posted, userHasDisplayPicture, userNickName;

- (void)dealloc {
	[userDisplayName release];
	[userNickName release];
	[qualifier release];
	[content release];
	[contentRaw release];
	[posted release];
	[super dealloc];
}

@end
