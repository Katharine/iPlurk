//
//  PlurkFriend.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	PlurkGenderFemale,
	PlurkGenderMale
} PlurkGender;


@interface PlurkFriend : NSObject {
	NSString *displayName;
	NSInteger uid;
	NSString *nickName;
	BOOL hasProfileImage;
	NSString *relationship;
	float karma;
	NSString *fullName;
	PlurkGender gender;
	NSString *pageTitle;
	NSString *location;
}

@property(nonatomic, retain) NSString *displayName;
@property NSInteger uid;
@property(nonatomic, retain) NSString *nickName;
@property BOOL hasProfileImage;
@property(nonatomic, retain) NSString *relationship;
@property float karma;
@property(nonatomic, retain) NSString *fullName;
@property PlurkGender gender;
@property(nonatomic, retain) NSString *pageTitle;
@property(nonatomic, retain) NSString *location;

@end
