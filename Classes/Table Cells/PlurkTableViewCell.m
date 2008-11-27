//
//  PlurkTableViewCell.m
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "PlurkTableViewCell.h"


@implementation PlurkTableViewCell
@synthesize imageButton;
@synthesize infoLabel;
@synthesize privatePlurkIcon;
@synthesize delegate;
@synthesize ownerID;
@synthesize plurkDisplayed;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		[infoLabel setFont:[UIFont systemFontOfSize:12.0]];
		NSLog(@"Cell init.");
    }
    return self;
}

- (void)updatePlurkMetadata {
	[self markAsWhateverItShouldBeMarkedAs];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
	if(selected) {
		[[self infoLabel] setHighlighted:YES];
	} else {
		if(animated) {
			NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[[self infoLabel] methodSignatureForSelector:@selector(setHighlighted:)]];
			[invoke setTarget:[self infoLabel]];
			[invoke setSelector:@selector(setHighlighted:)];
			BOOL no = NO;
			[invoke setArgument:&no atIndex:2];
			[invoke performSelector:@selector(invoke) withObject:nil afterDelay:0.5];
		} else {
			self.infoLabel.highlighted = NO;
		}
	}
	[self setContentSelected:selected animated:animated];
}

- (void)setContentSelected:(BOOL)selected animated:(BOOL)animated {
	NSLog(@"Override me!");
}


- (void)prepareForReuse {
	[self markAsRead];
	[[self imageButton] setImage:nil forState:UIControlStateNormal];
	[super prepareForReuse];
}

- (void)markAsUnread {
	UIImage *image = [UIImage imageNamed:@"UnreadIndicator.png"];
	UIImage *selectedImage = [UIImage imageNamed:@"SelectedUnreadIndicator.png"];
	if(!image || !selectedImage) {
		NSLog(@"Could not create image.");
	}
	[self setImage:image];
	[self setSelectedImage:selectedImage];
	[self setNeedsLayout];
}

- (void)markAsRead {
	[self renderLabel];
	[self setImage:nil];
	[self setSelectedImage:nil];
	[self setNeedsLayout];
}

- (void)markAsWhateverItShouldBeMarkedAs {
	if([[self plurkDisplayed] isUnread] == 1) {
		NSLog(@"Marking as unread.");
		[self markAsUnread];
	} else {
		NSLog(@"Marking as read.");
		[self markAsRead];
	}
	[self renderLabel];
}

- (void)renderLabel {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setDateFormat:@"EEE, dd MMM YYYY HH:mm"];
	[[self infoLabel] setText:[NSString stringWithFormat:@"%@ | %d response%@, %d unread", [formatter stringFromDate:[plurkDisplayed posted]], [plurkDisplayed responseCount], ([plurkDisplayed responseCount] != 1 ? @"s" : @""), ([plurkDisplayed responseCount] - [plurkDisplayed responsesSeen]), nil]];
	[formatter release];
}

- (void)displayPlurk:(Plurk *)plurk {
	self.ownerID = [plurk ownerID];
	self.plurkDisplayed = [plurk retain];
	[self renderPlurkText];
	[[self infoLabel] setFont:[UIFont systemFontOfSize:12.0]];
	[self renderLabel];
	if([[plurk limitedTo] count] > 0) {
		[[self privatePlurkIcon] setHidden: NO];
	} else {
		[[self privatePlurkIcon] setHidden: YES];
	}
}

- (void)renderPlurkText {
	NSLog(@"Override me!");
}

- (void)imageButtonClicked {
	// Do something about being clicked.
}

- (NSString *)modifyPlurkHtml:(NSString *)contentRaw {
	NSMutableString *content = [NSMutableString stringWithString:[contentRaw stringByReplacingOccurrencesOfRegex:@"<img src=\"(.+?)\".*?>" withString:@"$1"]];
	NSString *emoticonFormat = [NSString stringWithFormat:@"<img src=\"file://%@/emoticons/$1\">", [[NSBundle mainBundle] resourcePath], nil];
	[content replaceOccurrencesOfRegex:@"http://static.plurk.com/static/emoticons/((.+?)(\\.gif|\\.png))" withString:emoticonFormat];
	return content;
}

- (void)dealloc {
	NSLog(@"Deallocing cell.");
	//[infoLabel release];
	//[imageButton release];
	//[plurkDisplayed release];
    [super dealloc];
}


@end
