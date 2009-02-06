//
//  EmoticonPanelController.h
//  iPlurk
//
//  Created on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonSelectionTableViewController.h"

@interface EmoticonPanelController : UIViewController {
	UIView *modaliser;
	IBOutlet EmoticonSelectionTableViewController *tableController;
	id delegate;
	SEL action;
}

@property(nonatomic, retain) IBOutlet EmoticonSelectionTableViewController *tableController;
@property(nonatomic, assign) id delegate;
@property(nonatomic) SEL action;

- (IBAction)closePanel;
- (void)animateIn;

@end
