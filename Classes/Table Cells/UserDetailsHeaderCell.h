//
//  UserDetailsHeaderCell.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserDetailsHeaderCell : UITableViewCell {
	IBOutlet UIImageView *imageView;
	IBOutlet UILabel *label;
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UILabel *label;

@end
