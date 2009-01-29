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
- (UIColor *)getQualifierColour:(NSString *)qualifier;
- (NSString *)translateQualifier:(NSString *)qualifier to:(NSString *)language;

@end
