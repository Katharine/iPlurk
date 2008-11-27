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
	[htmlTemplate release];
	[qualifierCSS release];
	[super dealloc];
}

- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated {
	if(selected) {
		[plurkContent stringByEvaluatingJavaScriptFromString:@"document.body.style.color = 'white';"];
	} else {
		static NSString *script = @"document.body.style.color = 'black';";
		if(animated) {
			[plurkContent performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:script afterDelay:0.5];
		} else {
			[plurkContent stringByEvaluatingJavaScriptFromString:script];
		}
	}
}

- (void)initWithCoder:(NSCoder *)coder {
	htmlTemplate = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RichTextPlurkTableCell" ofType:@"html"]];
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"no_highlight_qualifiers"]) {
		qualifierCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Qualifiers" ofType:@"css"]];
	} else {
		qualifierCSS = @"";
	}
	[htmlTemplate retain];
	[qualifierCSS retain];
	[super initWithCoder:coder];
}


- (void)renderPlurkText {
	[[self plurkContent] setBackgroundColor:[UIColor clearColor]];
	Plurk* plurk = [self plurkDisplayed];
	NSString *html = [[NSString alloc] initWithFormat:htmlTemplate, qualifierCSS, [plurk ownerDisplayName], [plurk qualifier], ([[plurk qualifier] length] < 2 ? @"" : [plurk qualifier]), [self modifyPlurkHtml:[plurk content]], nil];
	[[WebViewManager manager] setUpWebView:[self plurkContent] withText:html];
	[html release];
}

@end
