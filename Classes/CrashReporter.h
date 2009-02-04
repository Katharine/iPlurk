//
//  CrashReporter.h
//  iPlurk
//
//  Created on 03/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CrashReporter/CrashReporter.h>


@interface CrashReporter : NSObject<UIAlertViewDelegate> {
	NSString *issueID;
}

+ (CrashReporter *)sharedReporter;

- (void)handleCrashReport;
- (BOOL)enableCrashReports;

@end
