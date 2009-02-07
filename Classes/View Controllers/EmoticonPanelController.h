//
//  EmoticonPanelController.h
//  iPlurk
//
//  Created on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlurkAPI.h"

@interface EmoticonPanelController : UIViewController<UIWebViewDelegate> {
	UIView *modaliser;
	IBOutlet UIWebView *webView;
	id delegate;
	SEL action;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, assign) id delegate;
@property(nonatomic) SEL action;

- (IBAction)closePanel;
- (void)animateIn;

@end
