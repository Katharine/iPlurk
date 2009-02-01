//
//  QualifierLanguageSelectorTableViewController.h
//  iPlurk
//
//  Created on 31/01/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Qualifiers.h"

@interface QualifierLanguageSelectorTableViewController : UITableViewController {
	NSArray *langs;
	NSString *selectedLang;
	id delegate;
	SEL action;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) SEL action;
@property(nonatomic, retain) NSString *selectedLang;

@end
