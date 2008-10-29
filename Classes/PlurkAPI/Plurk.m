//
//  Plurk.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "Plurk.h"

@implementation Plurk

@synthesize lang, contentRaw, qualifier, content, posted, limitedTo, ownerDisplayName;
@synthesize userID, plurkType, plurkID, responseCount, ownerID, responsesSeen, noComments, isUnread;

- (void)dealloc {
	[lang release];
	[contentRaw release];
	[qualifier release];
	[content release];
	[posted release];
	[limitedTo release];
	[ownerDisplayName release];
	[super dealloc];
}

- (BOOL)isEqual:(id)anObject {
	return [anObject isKindOfClass:[Plurk class]] && ([self plurkID] == [(Plurk *)anObject plurkID] || ([self ownerID] == [(Plurk *)anObject ownerID] && [[self posted] isEqualToDate:[(Plurk *)anObject posted]]));
}

- (NSUInteger)hash {
	return [self plurkID];
}

@end
