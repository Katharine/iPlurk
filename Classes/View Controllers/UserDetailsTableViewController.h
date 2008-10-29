//
//  UserDetailsTableViewController.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDetailsHeaderCell.h"
#import "UserDetailsDetailCell.h"
#import "PlurkFriend.h"
#import "ProfileImageCache.h"
#import "ButtonTableViewCell.h"

@interface UserDetailsTableViewController : UITableViewController {
	PlurkFriend *friend;
}

@property(nonatomic, retain) PlurkFriend *friend;

- (void)setPlurkFriend:(PlurkFriend *)newFriend;
- (void)dismiss;

@end
