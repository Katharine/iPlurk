//
//  MutableURLConnectionDictionary.m
//  iPlurk
//
//  Created on 14/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "MutableURLConnectionDictionary.h"

@implementation MutableURLConnectionDictionary

- (MutableURLConnectionDictionary *)init {
	if(self = [super init]) {
		dictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)setObject:(id)object forKey:(NSURLConnection *)key {
	NSNumber *number = [NSNumber numberWithUnsignedInteger:[key hash]];
	[dictionary setObject:object forKey:number];
}

- (void)removeObjectForKey:(NSURLConnection *)key {
	NSNumber *number = [NSNumber numberWithUnsignedInteger:[key hash]];
	[dictionary removeObjectForKey:number];
}

- (id)objectForKey:(NSURLConnection *)key {
	NSNumber *number = [NSNumber numberWithUnsignedInteger:[key hash]];
	return [dictionary objectForKey:number];
}

- (NSInteger)count {
	return [dictionary count];
}

@end
