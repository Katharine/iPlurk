//
//  ButtonTableViewCell.m
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "ButtonTableViewCell.h"


@implementation ButtonTableViewCell
@synthesize button;

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

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
	[button addTarget:target action:action forControlEvents:controlEvents];
}

- (NSString *)text {
	return [button titleForState:UIControlStateNormal];
}

- (NSString *)setText:(NSString *)text {
	[button setTitle:text forState:UIControlStateNormal];
	[button setTitle:text forState:UIControlStateHighlighted];
	[button setTitle:text forState:UIControlStateSelected];
	return text;
}

- (void)dealloc {
	[button release];
    [super dealloc];
}

- (IBAction)buttonDown {
	[self setSelected:YES animated:NO];
}

- (IBAction)buttonUp {
	[self setSelected:NO animated:NO];
}

@end
