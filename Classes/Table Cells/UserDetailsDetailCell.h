//
//  UserDetailsDetailCell.h
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserDetailsDetailCell : UITableViewCell {
	IBOutlet UILabel *label;
	IBOutlet UILabel *value;
}

@property(nonatomic, retain) UILabel *label;
@property(nonatomic, retain) UILabel *value;

@end
