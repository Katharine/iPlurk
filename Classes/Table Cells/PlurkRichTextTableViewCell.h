//
//  PlurkRichTextTableViewCell.h
//  iPlurk
//
//  Created on 13/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkTableViewCell.h"

@interface PlurkRichTextTableViewCell : PlurkTableViewCell {
	IBOutlet UIWebView *plurkContent;
	NSString *htmlTemplate;
	NSString *qualifierCSS;
}

@property(nonatomic, retain) UIWebView *plurkContent;

- (void)renderPlurkText;
- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated;

@end
