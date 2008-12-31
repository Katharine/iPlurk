//
//  PlurkFormatting.m
//  iPlurk
//
//  Created on 28/12/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkFormatting.h"
#import "RegexKitLite.h"

@implementation PlurkFormatting

+ (NSString *)addSmiliesToPlurk:(NSString *)plurkHTML {
	NSMutableString *content = [NSMutableString stringWithString:plurkHTML];
	NSString *emoticonPath = [NSString stringWithFormat:@"%@/statics/%%@", [[NSBundle mainBundle] resourcePath], nil];
	NSRange match = NSMakeRange(0, 0);
	while((match = [content rangeOfRegex:@"<img src=\"http://statics.plurk.com/(.+?)\"[^>]*?class=\"[^>]*?emoticon[^>]*?\"[^>]*?/>" options:RKLNoOptions inRange:NSMakeRange(match.location + match.length, [content length] - (match.location + match.length)) capture:1 error:NULL]).location != NSNotFound) {
		NSString *file = [content substringWithRange:match];
		NSString *newPath = [NSString stringWithFormat:emoticonPath, file, nil];
		NSString *newURL = [NSString stringWithFormat:@"file://%@", newPath, nil];
		NSLog(@"newPath: %@", newPath);
		if([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
			[content replaceOccurrencesOfString:[NSString stringWithFormat:@"http://statics.plurk.com/%@", file, nil] withString:newURL options:NSLiteralSearch range:NSMakeRange(0, [content length])];
			match.length += [newPath length] - [[NSString stringWithFormat:@"http://statics.plurk.com/", file, nil] length];
		}
	}
	return content;
}

+ (NSString *)avatarPathForUserID:(NSInteger)user {
	return [NSString stringWithFormat:@"%@user-%d.gif", [self avatarPath], user, nil];
}

+ (NSString *)avatarPath {
	return [NSString stringWithFormat:@"%@/tmp/avatars/", NSHomeDirectory(), nil];
}

@end
