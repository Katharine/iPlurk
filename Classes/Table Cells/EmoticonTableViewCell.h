//
//  EmoticonTableViewCell.h
//  iPlurk
//
//  Created by on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EmoticonTableViewCell : UITableViewCell {
	NSMutableArray *emoticonButtons;
	id delegate;
	SEL action;
	NSDictionary *images;
}

- (void)setEmoticons:(NSArray *)emoticons;
@property(nonatomic, assign) id delegate;
@property(nonatomic) SEL action;
@property(nonatomic, assign) NSDictionary *images;

@end
