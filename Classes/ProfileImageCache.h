//
//  ProfileImageCache.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ProfileImageCache : NSObject {
	NSMutableDictionary *userImages;
}

+ (ProfileImageCache *) mainCache;
- (ProfileImageCache *) init;
- (void)cacheImage:(UIImage *)image forUser:(NSInteger)user avatarNumber:(NSInteger)avatar;
- (void)removeImageForUser:(NSInteger)user;
- (void)emptyCache;
- (void)purgeDiskCache;
- (void)dealloc;
- (UIImage *)retrieveImageForUser:(NSInteger)user avatarNumber:(NSInteger)avatar;
- (UIImage *)retrieveImageForUser:(NSInteger)user;
- (BOOL)cacheContainsImageForUser:(NSInteger)user avatarNumber:(NSInteger)avatar;

@end
