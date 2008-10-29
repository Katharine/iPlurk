//
//  PlurkAPIRequest.m
//  iPlurk
//
//  Created on 14/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkAPIRequest.h"


@implementation PlurkAPIRequest
@synthesize data, delegate, action, storage, connection;

- (PlurkAPIRequest *)init {
	if(self = [super init]) {
		data = [[NSMutableData alloc] init];
		delegate = nil;
	}
	return self;
}

- (void)dealloc {
	[data release];
	[storage release];
	[connection release];
	[super dealloc];
}

@end
