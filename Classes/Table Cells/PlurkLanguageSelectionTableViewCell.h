//
//  PlurkLanguageSelectionTableViewCell.h
//  iPlurk
//
//  Created by on 30/01/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlurkLanguageSelectionTableViewCell : UITableViewCell {
	IBOutlet UILabel *languageLabel;
	IBOutlet UILabel *selectedLanguageLabel;
}

@property(nonatomic, retain) IBOutlet UILabel *languageLabel;
@property(nonatomic, retain) IBOutlet UILabel *selectedLanguageLabel;

- (NSString *)text;
- (void)setText:(NSString *)text;
- (void)initUI;

@end
