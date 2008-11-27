//
//  PlurkPlainTextTableViewCell.m
//  iPlurk
//
//  Created on 13/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkPlainTextTableViewCell.h"


@implementation PlurkPlainTextTableViewCell
@synthesize plurkContent, plurkNameAction;

- (void)dealloc {
	//[plurkContent release];
	//[plurkNameAction release];
	[super dealloc];
}

- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated {
	if(selected) {
		[plurkContent setTextColor:[UIColor whiteColor]];
		[plurkNameAction setTextColor:[UIColor whiteColor]];
	} else {
		if(animated) {
			[plurkContent performSelector:@selector(setTextColor:) withObject:[UIColor blackColor] afterDelay:0.5];
			[plurkNameAction performSelector:@selector(setTextColor:) withObject:[UIColor blackColor] afterDelay:0.5];
		} else {
			[plurkContent setTextColor:[UIColor blackColor]];
			[plurkNameAction setTextColor:[UIColor blackColor]];
		}
	}
}

- (void)renderPlurkText {
	Plurk *plurk = [self plurkDisplayed];
	[plurkNameAction setText:[NSString stringWithFormat:@"%@ %@", [plurk ownerDisplayName], ([[plurk qualifier] length] < 2 ? @"" : [plurk qualifier]), nil]];
	NSMutableString *content = [NSMutableString stringWithString:[plurk contentRaw]];
	[content replaceOccurrencesOfRegex:@"http://[^ ]+ \\((.+?)\\)" withString:@"$1"];
	[content appendString:@"\n\n\n\n\n"];
	
	[plurkContent setText:content];
	[[self plurkContent] setFont:[UIFont systemFontOfSize:12.0]];
	//[[self plurkContent] setNumberOfLines:0];
	[[self plurkNameAction] setFont:[UIFont boldSystemFontOfSize:12.0]];

}

@end
