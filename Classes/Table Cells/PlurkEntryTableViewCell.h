//
//  PlurkEntryTableViewCell.h
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlurkEntryTableViewCell : UITableViewCell <UITextViewDelegate> {
	IBOutlet UITextView *textView;
	IBOutlet UILabel *counterLabel;
	id changeTarget;
	SEL changeAction;
	BOOL qualifierEnabled;
	NSArray *qualifiers;
}

@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) IBOutlet UILabel *counterLabel;
@property(nonatomic) BOOL qualifierEnabled;

- (NSString *)text;
- (NSString *)setText:(NSString *)text;
- (NSString *)qualifier;
- (void)initUI;
- (void)setChangeAction:(SEL)action target:(id)target;

@end
