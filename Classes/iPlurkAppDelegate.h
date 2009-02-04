//
//  iPlurkAppDelegate.h
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright AjaxLife Developments 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrashReporter.h"
#import "UserTimelineTableViewController.h"

@interface iPlurkAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

