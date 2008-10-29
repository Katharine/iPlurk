//
//  UserDetailsDetailCell.m
//  iPlurk
//
//  Created on 12/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "UserDetailsDetailCell.h"


@implementation UserDetailsDetailCell
@synthesize label, value;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[label release];
	[value release];
    [super dealloc];
}


@end
