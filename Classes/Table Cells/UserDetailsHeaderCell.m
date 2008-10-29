//
//  UserDetailsHeaderCell.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "UserDetailsHeaderCell.h"


@implementation UserDetailsHeaderCell
@synthesize label, imageView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    }
	[self label].font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0];
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[label release];
	[imageView release];
    [super dealloc];
}


@end
