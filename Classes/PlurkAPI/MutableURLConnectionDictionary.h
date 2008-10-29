//
//  MutableURLConnectionDictionary.h
//  iPlurk
//
//  Created on 14/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MutableURLConnectionDictionary : NSObject {
	NSMutableDictionary *dictionary;
}

- (MutableURLConnectionDictionary *)init;
- (void)setObject:(id)object forKey:(NSURLConnection *)key;
- (void)removeObjectForKey:(NSURLConnection *)key;
- (id)objectForKey:(NSURLConnection *)key;
- (NSInteger)count;

@end
