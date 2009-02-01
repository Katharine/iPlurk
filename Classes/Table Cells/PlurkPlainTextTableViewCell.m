//
//  PlurkPlainTextTableViewCell.m
//  iPlurk
//
//  Created on 13/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkPlainTextTableViewCell.h"


@implementation PlurkPlainTextTableViewCell
@synthesize plurkContent, plurkNameAction, qualifierView, firstLine;

- (void)dealloc {
	//[plurkContent release];
	//[plurkNameAction release];
	[super dealloc];
}

- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated {
	if(selected) {
		[plurkContent setTextColor:[UIColor whiteColor]];
		[plurkNameAction setTextColor:[UIColor whiteColor]];
		[firstLine setTextColor:[UIColor whiteColor]];
	} else {
		if(animated) {
			[plurkContent performSelector:@selector(setTextColor:) withObject:[UIColor blackColor] afterDelay:0.5];
			[plurkNameAction performSelector:@selector(setTextColor:) withObject:[UIColor blackColor] afterDelay:0.5];
			[firstLine performSelector:@selector(setTextColor:) withObject:[UIColor blackColor] afterDelay:0.5];
		} else {
			[plurkContent setTextColor:[UIColor blackColor]];
			[plurkNameAction setTextColor:[UIColor blackColor]];
			[firstLine setTextColor:[UIColor blackColor]];
		}
	}
}

- (void)renderPlurkText {
	Plurk *plurk = [self plurkDisplayed];
	NSString *qualifier = [[Qualifiers sharedQualifiers] translateQualifier:[plurk qualifier] to:[plurk lang]];
	if(qualifier == nil) qualifier = [plurk qualifier];
	CGSize qualifierNameSize = CGSizeMake(0, 0);
	// If we aren't highlighting qualifiers
	if([[plurk qualifier] isEqualToString:@":"] || [[[NSUserDefaults standardUserDefaults] stringForKey:@"highlight_qualifiers"] isEqualToString:@"0"]) {
		[self renderTextQualifier:qualifier];
	} else {
		UIColor *qualifierColour = [[Qualifiers sharedQualifiers] colourForQualifier:[plurk qualifier]];
		if(qualifierColour) {
			[plurkNameAction setText:[plurk ownerDisplayName]];
			CGSize size = [[plurk ownerDisplayName] sizeWithFont:[UIFont boldSystemFontOfSize:12.0]];
			CGRect position = CGRectMake(96 + size.width + 3, 1, [qualifier sizeWithFont:[UIFont systemFontOfSize:12.0]].width + 6, 13);
			qualifierNameSize.width = 3 + position.size.width;
			[qualifierView setBackgroundColor:qualifierColour];
			[qualifierView setText:qualifier];
			[qualifierView setHidden:NO];
			[qualifierView setFrame:position];
		} else {
			[self renderTextQualifier:qualifier];
		}
	}
	NSMutableString *content = [NSMutableString stringWithString:[plurk contentRaw]];
	[content replaceOccurrencesOfRegex:@"http://[^ ]+ \\((.+?)\\)" withString:@"$1"];
	[content appendString:@"\n\n\n\n\n"];
	
	qualifierNameSize.width += [[plurkNameAction text] sizeWithFont:[UIFont boldSystemFontOfSize:12.0]].width;
	CGRect position = CGRectMake(96 + qualifierNameSize.width, 1, 295 - qualifierNameSize.width - 96, 14);
	[firstLine setFrame:position];
	NSMutableString *firstLineDisplay = [[NSMutableString alloc] init];
	NSMutableArray *words = [NSMutableArray arrayWithArray:[content componentsSeparatedByString:@" "]];
	while([words count] > 0 && [[NSString stringWithFormat:@"%@ %@",firstLineDisplay,[words objectAtIndex:0], nil] sizeWithFont:[UIFont systemFontOfSize:12.0]].width <= position.size.width) {
		[firstLineDisplay appendString:@" "];
		[firstLineDisplay appendString:[words objectAtIndex:0]];
		[words removeObjectAtIndex:0];
	}
	[firstLine setText:firstLineDisplay];
	[plurkContent setText:[words componentsJoinedByString:@" "]];
	[[self plurkContent] setFont:[UIFont systemFontOfSize:12.0]];
	[[self firstLine] setFont:[UIFont systemFontOfSize:12.0]];
	[[self qualifierView] setFont:[UIFont systemFontOfSize:12.0]];
	//[[self plurkContent] setNumberOfLines:0];
	[[self plurkNameAction] setFont:[UIFont boldSystemFontOfSize:12.0]];

}

- (void)renderTextQualifier:(NSString *)qualifier {
	[qualifierView setHidden:YES];
	[plurkNameAction setText:[NSString stringWithFormat:@"%@ %@", [[self plurkDisplayed] ownerDisplayName], ([qualifier length] < 2 ? @"" : qualifier), nil]];
}

@end
