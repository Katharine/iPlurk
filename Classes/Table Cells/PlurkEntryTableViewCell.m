//
//  PlurkEntryTableViewCell.m
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkEntryTableViewCell.h"


@implementation PlurkEntryTableViewCell
@synthesize textView, counterLabel, qualifierEnabled;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}
- (BOOL)textView:(UITextView *)view shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if([text isEqual:@"\n"]) {
		[view resignFirstResponder];
		return NO;
	}
	
	NSInteger charactersRemaining = 140 - [[textView text] length] - ([text length] > 0 ? 1 : -1) + [[self qualifier] length];
	if(charactersRemaining < 0 && [text length] > 0) {
		return NO;
	}
	return YES;
}

- (void)initUI {
	[counterLabel setFont:[UIFont systemFontOfSize:12.0]];
	[textView setFont:[UIFont systemFontOfSize:12.0]];
	qualifiers = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Qualifiers" ofType:@"plist"]] retain];
	qualifierEnabled = YES;
	[textView setReturnKeyType:UIReturnKeyDone];
}

- (void)textViewDidChange:(UITextView *)view {
	NSInteger charactersRemaining = 140 - [[textView text] length] + (qualifierEnabled ? [[self translated] length] : 0);
	[[self counterLabel] setText:[NSString stringWithFormat:@"%d characters remaining", charactersRemaining, nil]];
	if(changeTarget && changeAction) {
		[changeTarget performSelector:changeAction withObject:[textView text]];
	}
}

- (void)setQualifierEnabled:(BOOL)enabled {
	qualifierEnabled = enabled;
	[self textViewDidChange:textView];
	//return enabled;
}

- (void)setChangeAction:(SEL)action target:(id)target {
	changeAction = action;
	changeTarget = target;
}

- (NSString *)text {
	if(![self qualifier]) {
		return [[self textView] text];
	} else {
		return [[[[self textView] text] substringFromIndex:[[self qualifier] length]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
}

- (NSString *)setText:(NSString *)text {
	NSString *cutText = [text length] > 140 ? [text substringToIndex:140] : text;
	[[self textView] setText:cutText];
	[[self counterLabel] setText:[NSString stringWithFormat:@"%d characters remaining", 140 - [cutText length], nil]];
	return cutText;
}

- (NSString *)qualifier {
	if(!qualifierEnabled) return nil;
	NSString *text = [[[self textView] text] lowercaseString];
	for(NSString *qual in qualifiers) {
		if([qual isEqualToString:@":"]) continue;
		NSString *translation = [[Qualifiers sharedQualifiers] translateQualifier:qual to:language];
		if([translation length] == 0) continue;
		if([text hasPrefix:translation]) return qual;
	}
	return nil;
}

- (NSString *)translated {
	NSString *qual = [self qualifier]; // This is somewhat tedious to find.
	NSString *translation = [[Qualifiers sharedQualifiers] translateQualifier:qual to:language];
	if(translation && [translation length] > 0 && [qual length] > 1) {
		return translation;
	}
	return [self qualifier];
}

- (void)setLanguage:(NSString *)lang {
	if([language isEqualToString:lang]) return;
	[language release];
	language = [lang retain];
	[self textViewDidChange:textView]; // Recount and such.
}

- (NSString *)language {
	return language;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [super dealloc];
}


@end
