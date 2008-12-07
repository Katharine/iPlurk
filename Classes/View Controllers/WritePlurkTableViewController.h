//
//  PlurkReplyTableViewController.h
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkAPI.h"
#import "PlurkEntryTableViewCell.h"
#import "PlurkQualifierTableViewCell.h"
#import "ButtonTableViewCell.h"
#import "QualifierSelectorTableViewController.h"
#import "PlurkResponsesViewController.h"

@interface WritePlurkTableViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	Plurk *plurkToReplyTo;
	Plurk *plurkToEdit;
	Plurk *currentPlurk;
	BOOL creatingNewPlurk;
	PlurkEntryTableViewCell *entryCell;
	PlurkQualifierTableViewCell *qualifierCell;
	IBOutlet QualifierSelectorTableViewController *qualifierTable;
	BOOL tryingToQuit;
	BOOL firstView;
	NSString *initialContent;
	NSString *initialQualifier;
}

@property(nonatomic, retain) Plurk *plurkToReplyTo;
@property(nonatomic, retain) Plurk *plurkToEdit;
@property(nonatomic) BOOL creatingNewPlurk;
@property(nonatomic, retain) PlurkEntryTableViewCell *entryCell;
@property(nonatomic, retain) PlurkQualifierTableViewCell *qualifierCell;
@property(nonatomic, retain) IBOutlet QualifierSelectorTableViewController *qualifierTable;
@property(nonatomic, retain) NSString *initialContent;
@property(nonatomic, retain) NSString *initialQualifier;

- (void)submitReply;
- (void)startPhotoChooser;
- (void)confirmBackButton;
- (void)replyDidChange:(NSString *)text;

@end
