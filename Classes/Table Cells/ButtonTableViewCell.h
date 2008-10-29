//
//  ButtonTableViewCell.h
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ButtonTableViewCell : UITableViewCell {
	IBOutlet UIButton *button;
}

@property(nonatomic, retain) IBOutlet UIButton *button;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (IBAction)buttonDown;
- (IBAction)buttonUp;

@end
