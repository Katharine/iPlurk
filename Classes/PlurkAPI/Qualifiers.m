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

+ (NSArray *)list {
	static NSArray *list;
	if(list == nil) {
		list = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Qualifiers" ofType:@"plist"]] retain];
	}
	return list;
}

+ (NSDictionary *)languages {
	static NSDictionary *list;
	if(list == nil) {
		list = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QualifierLanguages" ofType:@"plist"]] retain];
	}
	return list;
}

+ (NSString *)defaultQualifier {
	return [[Qualifiers list] objectAtIndex:0];
}

+ (NSString *)defaultLanguage {
	NSString *language = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
	if([[Qualifiers languages] objectForKey:language] != nil) {
		return language;
	}
	return @"en";
}

- (Qualifiers *)init {
	if(self = [super init]) {
		qualifiers = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QualifierDetails" ofType:@"plist"]] retain];
	}
	return self;
}

- (UIColor *)colourForQualifier:(NSString *)qualifier {
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
