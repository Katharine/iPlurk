//
//  EmoticonTableViewCell.m
//  iPlurk
//
//  Created on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import "EmoticonTableViewCell.h"


@implementation EmoticonTableViewCell
@synthesize delegate, action, images;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		if(!emoticonButtons) emoticonButtons = [[[NSMutableArray alloc] init] retain];
    }
    return self;
}

- (void)setEmoticons:(NSArray *)emoticons {
	while([emoticons count] < [emoticonButtons count]) {
		[[emoticonButtons lastObject] removeFromSuperview];
		[emoticonButtons removeLastObject];
	}
	NSInteger i;
	while([emoticons count] > (i = [emoticonButtons count])) {
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(64 * i, 0, 64, 50)];
		[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
		[emoticonButtons addObject:button];
	}
	NSInteger num = 0;
	for(NSDictionary *dict in emoticons) {
		UIButton *button = [emoticonButtons objectAtIndex:num];
		UIImage *image = [images objectForKey:[dict objectForKey:@"name"]];
		[button setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
		[button setFrame:CGRectMake(64 * num + 32 - [image size].width / 2, (50 - [image size].height) / 2, [image size].width, [image size].height)];
		[button setImage:image forState:UIControlStateNormal];
		++num;
	}
}

- (void)buttonPressed:(UIButton *)pressed {
	[delegate performSelector:action withObject:[pressed titleForState:UIControlStateNormal]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

//    [super setSelected:selected animated:animated];
// Do nothing.
    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
