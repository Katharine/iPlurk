//
//  PlurkQualifierTableViewCell.m
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkQualifierTableViewCell.h"


@implementation PlurkQualifierTableViewCell
@synthesize name, qualifier;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
	if(selected) {
		[name setTextColor:[UIColor whiteColor]];
		[qualifier setTextColor:[UIColor whiteColor]];
	} else {
		[name setTextColor:[UIColor blackColor]];
		[qualifier setTextColor:[UIColor blackColor]];
	}
}

- (void)initUI {
	[name setFont:[UIFont boldSystemFontOfSize:17.0]];
}


- (void)dealloc {
	[name release];
	[qualifier release];
    [super dealloc];
}


@end
