//
//  LoadMorePlurksCell.m
//  iPlurk
//
//  Created on 14/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "LoadMorePlurksCell.h"


@implementation LoadMorePlurksCell
@synthesize spinner, label;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	if(selected) {
		[[self label] setTextColor:[UIColor whiteColor]];
	} else {
		if(animated) {
			[[self label] performSelector:@selector(setTextColor:) withObject:[UIColor blackColor] afterDelay:0.25];
		} else {
			[[self label] setTextColor:[UIColor blackColor]];
		}
	}
    // Configure the view for the selected state
}


- (void)dealloc {
	[spinner release];
	[label release];
    [super dealloc];
}


@end
