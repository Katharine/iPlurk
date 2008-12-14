//
//  ProfileImageCache.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "ProfileImageCache.h"


@implementation ProfileImageCache

+ (ProfileImageCache *) mainCache {
	static ProfileImageCache *cache;
	if(!cache) {
		cache = [[ProfileImageCache alloc] init];
	}
	return cache;
}

- (ProfileImageCache *) init {
	userImages = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)cacheImage:(UIImage *)image forUser:(NSInteger)user {
	if(!image) return;
	if([userImages respondsToSelector:@selector(setObject:forKey:)]) {
		[userImages setObject:image forKey:[NSNumber numberWithInteger:user]];
	} else {
		//NSLog(@"ERROR: userImages isn't a mutable dictionary!");
		[userImages release];
		[self init];
	}
}

- (void)removeImageForUser:(NSInteger)user {
	[userImages removeObjectForKey:[NSNumber numberWithInteger:user]];
}

- (void)emptyCache {
	[userImages removeAllObjects];
}

- (UIImage *)retrieveImageForUser:(NSInteger)user {
	return [userImages objectForKey:[NSNumber numberWithInteger:user]];
}

- (BOOL)cacheContainsImageForUser:(NSInteger)user {
	return [userImages objectForKey:[NSNumber numberWithInteger:user]] == nil;
}

- (void)dealloc {
	[userImages release];
	[super dealloc];
}

@end
