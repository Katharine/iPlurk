//
//  Qualifiers.h
//  iPlurk
//
//  Created on 29/01/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Qualifiers : NSObject {
	NSDictionary *qualifiers;
}

+ (Qualifiers *)sharedQualifiers;
+ (NSArray *)list;
+ (NSDictionary *)languages;
+ (NSString *)defaultQualifier;
+ (NSString *)defaultLanguage;

- (UIColor *)colourForQualifier:(NSString *)qualifier;
- (NSString *)translateQualifier:(NSString *)qualifier to:(NSString *)language;

@end
