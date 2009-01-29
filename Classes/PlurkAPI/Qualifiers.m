//
//  Qualifiers.m
//  iPlurk
//
//  Created on 29/01/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import "Qualifiers.h"


@implementation Qualifiers
+ (Qualifiers *)sharedQualifiers {
	static Qualifiers* shared;
	if(shared == nil) {
		shared = [[Qualifiers alloc] init];
	}
	return shared;
}

- (Qualifiers *)init {
	if(self = [super init]) {
		qualifiers = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QualifierDetails" ofType:@"plist"]] retain];
	}
	return self;
}

- (UIColor *)getQualifierColour:(NSString *)qualifier {
	NSDictionary *data = [qualifiers objectForKey:qualifier];
	if(data == nil) return nil;
	UIColor *colour = [UIColor colorWithRed:[[data objectForKey:@"ColourRed"] floatValue]
									  green:[[data objectForKey:@"ColourGreen"] floatValue]
									   blue:[[data objectForKey:@"ColourBlue"] floatValue]
									  alpha:1.0
	];
	return colour;
}

- (NSString *)translateQualifier:(NSString *)qualifier to:(NSString *)language {
	return [[[qualifiers objectForKey:qualifier] objectForKey:@"Translations"] objectForKey:language];
}

@end
