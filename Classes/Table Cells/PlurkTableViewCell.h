//
//  PlurkTableViewCell.h
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewManager.h"
#import "PlurkTableCellProtocol.h"
#import "Plurk.h"
#import "RegexKitLite.h"

@interface PlurkTableViewCell : UITableViewCell <PlurkTableCellProtocol> {
	IBOutlet UIButton *imageButton;
	IBOutlet UILabel *infoLabel;
	IBOutlet UIImageView *privatePlurkIcon;
	NSInteger ownerID;
	Plurk *plurkDisplayed;
	id delegate;
}

@property(nonatomic, retain) UIButton *imageButton;
@property(nonatomic, retain) UILabel *infoLabel;
@property(nonatomic, retain) UIImageView *privatePlurkIcon;
@property(nonatomic, retain) id delegate;
@property(nonatomic, retain) Plurk *plurkDisplayed;
@property NSInteger ownerID;

- (void)markAsRead;
- (void)markAsUnread;
- (void)markAsWhateverItShouldBeMarkedAs;
- (void)renderPlurkText;
- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated;
- (void)displayPlurk:(Plurk *)plurk;
- (void)updatePlurkMetadata;
- (void)renderLabel;
- (IBAction)imageButtonClicked;

@end
