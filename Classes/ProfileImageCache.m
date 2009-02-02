//
//  ProfileImageCache.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "ProfileImageCache.h"

static sqlite3 *database = nil;
static sqlite3_stmt *insert = nil;
static sqlite3_stmt *sel = nil;
static sqlite3_stmt *sel_unpicky = nil;

@implementation ProfileImageCache

+ (ProfileImageCache *) mainCache {
	static ProfileImageCache *cache;
	if(!cache) {
		cache = [[ProfileImageCache alloc] init];
	}
	return cache;
}

- (NSString *)dbpath {
	return [NSString stringWithFormat:@"%@/tmp/AvatarCache.sql", NSHomeDirectory(), nil];
}

- (ProfileImageCache *) init {
	userImages = [[NSMutableDictionary alloc] init];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:[self dbpath]]) {
		[[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"AvatarCache" ofType:@"sql"]  toPath:[self dbpath] error:NULL];
		NSLog(@"Copied database template.");
	}
	
	if(sqlite3_open([[self dbpath] UTF8String], &database) != SQLITE_OK) {
		[[NSException exceptionWithName:@"DatabaseConnectionFailure" reason:@"Couldn't connect to database." userInfo:nil] raise];
	}
	return self;
}

- (void)cacheImage:(UIImage *)image forUser:(NSInteger)user avatarNumber:(NSInteger)avatar {
	if(!image) return;
	if([userImages respondsToSelector:@selector(setObject:forKey:)]) {
		// Hold it in memory.
		[userImages setObject:image forKey:[NSNumber numberWithInteger:user]];
		
		// Stick it in the database. :D
		NSLog(@"Storing avatar image in database.");
		if(insert == nil) {
			const char *sql = "REPLACE INTO avatars VALUES (?, ?, ?)";
			if(sqlite3_prepare_v2(database, sql, -1, &insert, NULL) != SQLITE_OK) {
				[[NSException exceptionWithName:@"DatabasePrepareFailure" reason:[NSString stringWithUTF8String:sqlite3_errmsg(database)] userInfo:nil] raise];
			}
		}
		
		sqlite3_bind_int(insert, 1, user);
		sqlite3_bind_int(insert, 2, avatar);
		NSData *dat = UIImagePNGRepresentation(image);
		sqlite3_bind_blob(insert, 3, [dat bytes], [dat length], SQLITE_STATIC);
		
		if(sqlite3_step(insert) != SQLITE_DONE) {
			[[NSException exceptionWithName:@"DatabaseExecutionError" reason:[NSString stringWithUTF8String:sqlite3_errmsg(database)] userInfo:nil] raise];
		}
		
		sqlite3_reset(insert);
	} else {
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

- (void)purgeDiskCache {
	if(database != nil) {
		if(insert != nil) {
			sqlite3_finalize(insert);
			insert = nil;
		}
		if(sel != nil) {
			sqlite3_finalize(sel);
			sel = nil;
		}
		if(sel_unpicky != nil) {
			sqlite3_finalize(sel_unpicky);
			sel = nil;
		}
		sqlite3_close(database);
		database = nil;
	}
	[[NSFileManager defaultManager] removeItemAtPath:[self dbpath] error:NULL];
	[self init];
	return;
}

- (UIImage *)retrieveImageForUser:(NSInteger)user {
	return [self retrieveImageForUser:user avatarNumber:-1];
}

- (UIImage *)retrieveImageForUser:(NSInteger)user avatarNumber:(NSInteger)avatar {
	UIImage *result = [userImages objectForKey:[NSNumber numberWithInteger:user]];
	if(result != nil) {
		NSLog(@"Had image for %d/%d in memory.", user, avatar);
		return result;
	}
	
	// Try looking it up in the database.
	sqlite3_stmt *actual;
	if(avatar < 0) {
		actual = sel_unpicky;
	} else {
		actual = sel;
	}
	char *sql;
	if(actual == nil && avatar < 0) {
		sql = "SELECT image FROM avatars WHERE userid = ?";
	} else if(actual == nil) {
		sql = "SELECT image FROM avatars WHERE userid = ? AND avatarnum = ?";
	}
	
	if(sqlite3_prepare_v2(database, sql, -1, &actual, NULL) != SQLITE_OK) {
		[[NSException exceptionWithName:@"DatabasePrepareFailure" reason:[NSString stringWithUTF8String:sqlite3_errmsg(database)] userInfo:nil] raise];
	}
	
	NSLog(@"Looking for %d/%d in database.", user, avatar);
	sqlite3_bind_int(actual, 1, user);
	if(avatar >= 0) {
		sqlite3_bind_int(actual, 2, avatar);
	}
	
	if(sqlite3_step(actual) != SQLITE_ROW) {
		NSLog(@"Not in database. D:");
		return nil;
	}
	
	NSLog(@"Row exists!");
	NSData *image = [NSData dataWithBytes:sqlite3_column_blob(actual, 0) length:sqlite3_column_bytes(actual, 0)];
	NSLog(@"Image length: %d", [image length]);
	sqlite3_reset(actual);
	return [UIImage imageWithData:image];
}

- (BOOL)cacheContainsImageForUser:(NSInteger)user avatarNumber:(NSInteger)avatar {
	return [self retrieveImageForUser:user avatarNumber:avatar] == nil;
}

- (void)dealloc {
	if(database != nil) sqlite3_close(database);
	if(insert != nil) sqlite3_finalize(insert);
	if(sel != nil) sqlite3_finalize(sel);
	if(sel_unpicky != nil) sqlite3_finalize(sel_unpicky);
	
	[userImages release];
	[super dealloc];
}

@end
