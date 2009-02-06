//
//  EmoticonSelectionTableViewController.h
//  iPlurk
//
//  Created on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonTableViewCell.h"
#import "PlurkAPI.h"

@interface EmoticonSelectionTableViewController : UITableViewController {
	NSMutableArray *emoticons;
	NSMutableDictionary *emoticonImages;
	IBOutlet UITableView *table;
	id delegate;
	SEL action;
}

@property(nonatomic, retain) UITableView *table;
@property(nonatomic, assign) id delegate;
@property(nonatomic) SEL action;

- (void)doSetup;

@end
