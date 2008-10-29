//
//  PlurkRichTextTableViewCell.m
//  iPlurk
//
//  Created on 13/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkRichTextTableViewCell.h"

@implementation PlurkRichTextTableViewCell
@synthesize plurkContent;

- (void)dealloc {
	[plurkContent release];
	[super dealloc];
}

- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated {
	if(selected) {
		[plurkContent stringByEvaluatingJavaScriptFromString:@"document.body.style.color = 'white';"];
	} else {
		[plurkContent stringByEvaluatingJavaScriptFromString:@"document.body.style.color = 'black';"];
	}
}


- (void)renderPlurkText {
	[[self plurkContent] setBackgroundColor:[UIColor clearColor]];
	Plurk* plurk = [self plurkDisplayed];
	static NSString *FormatString = @"<html><head><style type='text/css'>* { background-color: transparent; } body, html { font-family: sans-serif; font-size: 12px; padding: 0px; margin: 0px; }</style></head><body><strong>%@</strong> %@ %@</body></html>";
	NSString *html = [[NSString alloc] initWithFormat:FormatString, [plurk ownerDisplayName], ([[plurk qualifier] length] < 2 ? @"" : [plurk qualifier]), [self modifyPlurkHtml:[plurk content]], nil];
	[[WebViewManager manager] setUpWebView:[self plurkContent] withText:html];
	[html release];
}

@end
