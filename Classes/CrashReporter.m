//
//  CrashReporter.m
//  iPlurk
//
//  Created on 03/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import "CrashReporter.h"


@implementation CrashReporter

+ (CrashReporter *)sharedReporter {
	static CrashReporter *shared;
	if(shared == nil) {
		shared = [[CrashReporter alloc] init];
	}
	return shared;
}

- (BOOL)enableCrashReports {
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"crash_reporting"]) {
		PLCrashReporter *reporter = [PLCrashReporter sharedReporter];
		if([reporter hasPendingCrashReport]) {
			[self handleCrashReport];
		}
		
		if(![reporter enableCrashReporter]) {
			NSLog(@"Couldn't enable crash reporter!");
			return NO;
		}
	}
	return YES;
}

- (void)handleCrashReport {
	NSData *crashReport = [[PLCrashReporter sharedReporter] loadPendingCrashReportData];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://crash.plu.cc/report.php"]];
	[request setHTTPBody:crashReport];
	[request setValue:[[NSNumber numberWithInteger:[crashReport length]] stringValue] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	NSError *error;
	NSURLResponse *resp;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
	if(response) {
		issueID = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] retain];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Crash report"
														message:[NSString 
																 stringWithFormat:@"It seems that iPlurk crashed the last time it ran.\nIf you wish to provide further information to the developer, please provide the following number:\n\n%@", 
																 issueID, nil]
													   delegate:self
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:@"Contact", nil
							  ];
		[alert show];
		[alert release];
	} else {
		NSLog(@"Couldn't report crash: %@", [error localizedDescription]);
	}
	[[PLCrashReporter sharedReporter] purgePendingCrashReport];
}

- (void)alertView:(UIAlertView *)view clickedButtonAtIndex:(NSInteger)index {
	if(index != [view cancelButtonIndex]) {
		// We're meant to email the thing.
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:support@iplurkapp.com?subject=iPlurk%%20Crash%%20Report&body=%@", issueID, nil]];
		[[UIApplication sharedApplication] openURL:url];
	}
	[issueID release];
}

@end
