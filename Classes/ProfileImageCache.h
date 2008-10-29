//
//  ProfileImageCache.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileImageCache : NSObject {
	NSMutableDictionary *userImages;
}

+ (ProfileImageCache *) mainCache;
- (ProfileImageCache *) init;
- (void)cacheImage:(UIImage *)image forUser:(NSInteger)user;
- (void)removeImageForUser:(NSInteger)user;
- (void)emptyCache;
- (void)dealloc;
- (UIImage *)retrieveImageForUser:(NSInteger)user;
- (BOOL)cacheContainsImageForUser:(NSInteger)user;

@end
