//
//  PlurkPlainTextTableViewCell.h
//  iPlurk
//
//  Created on 13/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkTableViewCell.h"


@interface PlurkPlainTextTableViewCell : PlurkTableViewCell {
	IBOutlet UILabel *plurkContent;
	IBOutlet UILabel *plurkNameAction;
}

@property(nonatomic, retain) IBOutlet UILabel *plurkContent;
@property(nonatomic, retain) IBOutlet UILabel *plurkNameAction;

- (void)renderPlurkText;
- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated;

@end
