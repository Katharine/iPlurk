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
#import "PlurkLanguageSelectionTableViewCell.h"
#import "QualifierLanguageSelectorTableViewController.h"
#import "Qualifiers.h"
#import "EmoticonPanelController.h"

@interface WritePlurkTableViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	Plurk *plurkToReplyTo;
	Plurk *plurkToEdit;
	Plurk *currentPlurk;
	BOOL creatingNewPlurk;
	PlurkEntryTableViewCell *entryCell;
	PlurkQualifierTableViewCell *qualifierCell;
	PlurkLanguageSelectionTableViewCell *languageCell;
	IBOutlet QualifierSelectorTableViewController *qualifierTable;
	IBOutlet QualifierLanguageSelectorTableViewController *languageTable;
	BOOL tryingToQuit;
	BOOL firstView;
	NSString *initialContent;
	NSString *initialQualifier;
	NSString *qualifierLanguage;
	NSString *qualifier;
	BOOL allowInteraction;
}

@property(nonatomic, retain) Plurk *plurkToReplyTo;
@property(nonatomic, retain) Plurk *plurkToEdit;
@property(nonatomic) BOOL creatingNewPlurk;
@property(nonatomic, retain) PlurkEntryTableViewCell *entryCell;
@property(nonatomic, retain) PlurkQualifierTableViewCell *qualifierCell;
@property(nonatomic, retain) PlurkLanguageSelectionTableViewCell *languageCell;
@property(nonatomic, retain) IBOutlet QualifierSelectorTableViewController *qualifierTable;
@property(nonatomic, retain) IBOutlet QualifierLanguageSelectorTableViewController *languageTable;
@property(nonatomic, retain) NSString *initialContent;
@property(nonatomic, retain) NSString *initialQualifier;

- (void)submitReply;
- (void)startPhotoChooser;
- (void)confirmBackButton;
- (void)replyDidChange:(NSString *)text;
- (void)setQualifierLanguage:(NSString *)language;
- (void)startEmoticonSelector;

@end
