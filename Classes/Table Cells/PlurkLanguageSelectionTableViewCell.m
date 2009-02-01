//
//  PlurkLanguageSelectionTableViewCell.m
//  iPlurk
//
//  Created by on 30/01/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import "PlurkLanguageSelectionTableViewCell.h"


@implementation PlurkLanguageSelectionTableViewCell
@synthesize languageLabel, selectedLanguageLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initUI {
	[languageLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
}

- (NSString *)text {
	return [selectedLanguageLabel text];
}

- (void)setText:(NSString *)text {
	[selectedLanguageLabel setText:text];
}

- (void)dealloc {
    [super dealloc];
}


@end
