//
//  PlurkFriend.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkFriend.h"


@implementation PlurkFriend
@synthesize fullName, displayName, nickName, relationship, pageTitle, location, avatar;
@synthesize uid, hasProfileImage, karma, gender;

- (void)dealloc {
	[displayName release];
	[nickName release];
	[relationship release];
	[fullName release];
	[pageTitle release];
	[location release];
	[avatar release];
	[super dealloc];
}

@end
