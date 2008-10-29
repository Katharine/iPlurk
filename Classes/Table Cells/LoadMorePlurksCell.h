//
//  LoadMorePlurksCell.h
//  iPlurk
//
//  Created on 14/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadMorePlurksCell : UITableViewCell {
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UILabel *label;
}

@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UILabel *label;

@end
