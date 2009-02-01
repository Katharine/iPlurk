//
//  QualifierSelectorTableViewController.h
//  iPlurk
//
//  Created on 19/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Qualifiers.h"


@interface QualifierSelectorTableViewController : UITableViewController {
	NSString *qualifier;
	id delegate;
	SEL action;
	NSString *language;
	NSMutableArray *translations;
}

@property(nonatomic, retain) NSString *qualifier;
@property(nonatomic, assign) id delegate;
@property(nonatomic) SEL action;
@property(nonatomic, retain) NSString *language;

@end
