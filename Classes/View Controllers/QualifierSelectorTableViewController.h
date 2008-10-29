//
//  QualifierSelectorTableViewController.h
//  iPlurk
//
//  Created on 19/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QualifierSelectorTableViewController : UITableViewController {
	NSString *qualifier;
	NSArray *qualifiers;
}

@property(nonatomic, retain) NSString *qualifier;

@end
