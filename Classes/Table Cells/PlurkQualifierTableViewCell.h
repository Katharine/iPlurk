//
//  PlurkQualifierTableViewCell.h
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlurkQualifierTableViewCell : UITableViewCell {
	IBOutlet UILabel *name;
	IBOutlet UILabel *qualifier;
}

@property(nonatomic, retain) IBOutlet UILabel *name;
@property(nonatomic, retain) IBOutlet UILabel *qualifier;

- (void)initUI;

@end
