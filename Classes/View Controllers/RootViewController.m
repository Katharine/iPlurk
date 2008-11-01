//
//  RootViewController.m
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright AjaxLife Developments 2008. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController
@synthesize plurks, unreadPlurks, privatePlurks, currentPlurks;
@synthesize plurkAPI;
@synthesize setupViewController;
@synthesize userDetailsController;
@synthesize tabs;

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(currentTab == RootViewTabAll && [plurks count] > 0) {
		return [currentPlurks count] + 1;
	}
    return [currentPlurks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Special case: "Load more plurks" cell
	if(currentTab == RootViewTabAll && [indexPath row] >= [plurks count]) {
		LoadMorePlurksCell *cell = nil;
		cell = (LoadMorePlurksCell *)[tableView dequeueReusableCellWithIdentifier:@"LoadMorePlurksCell"];
		if(cell == nil) {
			UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"LoadMorePlurksCell" bundle:nil];
			cell = (LoadMorePlurksCell *)viewController.view;
			[viewController release];
		}
		return cell;
	}
	
	// Produce a cell from somewhere.
    PlurkTableViewCell *cell = nil;
	cell = (PlurkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:plurkTableCellType];
    if (cell == nil) {
        UIViewController *viewController = [[UIViewController alloc] initWithNibName:plurkTableCellType bundle:nil];
		cell = (PlurkTableViewCell *)viewController.view;
		[viewController release];
    }
	
	// Find the right plurk
	Plurk *plurk = [currentPlurks objectAtIndex:indexPath.row];
	PlurkFriend *friend = [[plurkAPI friendDictionary] objectForKey:[plurkAPI nickNameFromUserID:[plurk ownerID]]];
	
	// Display text
	[cell displayPlurk:plurk];
	
	// Mark is unread if it's unread.
	if([plurk isUnread] == 1) {
		[cell markAsUnread];
	}
	
	// Try loading a cached image, if we want one at all.
	if([friend hasProfileImage]) {
		UIImage *avatar = nil;
		avatar = [[ProfileImageCache mainCache] retrieveImageForUser:[plurk ownerID]];
		if(!avatar) {
			NSString *pathToImage = [NSString stringWithFormat:@"%@/user-%d.gif", imageCacheDirectory, [plurk ownerID], nil];
			NSLog(@"Looking for image in %@", pathToImage);
			if([[NSFileManager defaultManager] fileExistsAtPath:pathToImage]) {
				avatar = [UIImage imageWithContentsOfFile:pathToImage];
				[[ProfileImageCache mainCache] cacheImage:avatar forUser:[plurk ownerID]];
			}
			if(!avatar) {
				// No cached image. Go get it.
				NSURL *avatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://avatars.plurk.com/%d-medium.gif", [plurk ownerID], nil]];
				FileDownloader *downloader = [[FileDownloader alloc] initFromURL:avatarUrl toFile:pathToImage notify:self];
				[downloader release];
			}
		}
		if(avatar) {
			[[cell imageButton] setImage:[avatar retain] forState:UIControlStateNormal];
		}
	}
	
	// Link up the button
	cell.delegate = self;
	
	//[indexPath release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic -- create and push a new view controller
	if([indexPath row] >= [currentPlurks count]) {
		if(!allRequest) {
			allRequest = [plurkAPI requestPlurksStartingFrom:[[[currentPlurks lastObject] posted] addTimeInterval:1.0] endingAt:nil onlyPrivate:NO delegate:self];
			[[(LoadMorePlurksCell *)[tableView cellForRowAtIndexPath:indexPath] spinner] startAnimating];
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		[selectedPlurk release];
		selectedRow = [indexPath row];
		selectedPlurk = [[currentPlurks objectAtIndex:selectedRow] retain];
		PlurkResponsesViewController *controller = [[PlurkResponsesViewController alloc] initWithNibName:@"PlurkResponsesView" bundle:nil];
		controller.firstPlurk = selectedPlurk;
		controller.avatarPath = imageCacheDirectory;
		controller.emoticonPath = [NSString stringWithFormat:@"%@/emoticons/", [[NSBundle mainBundle] resourcePath], nil];
		controller.plurkAPI = plurkAPI;
		controller.delegate = self;
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		//[(PlurkTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] markAsRead];
	}
}

#pragma mark Interface Builder

- (IBAction)tabHasChanged {
	NSLog(@"TabHasChanged.");
	currentTab = (RootViewTab)[tabs selectedSegmentIndex];
	if(currentTab == UISegmentedControlNoSegment) currentTab = RootViewTabAll;
	switch (currentTab) {
		case RootViewTabAll:
			currentPlurks = plurks;
			break;
		case RootViewTabUnread:
			currentPlurks = unreadPlurks;
			break;
		case RootViewTabPrivate:
			currentPlurks = privatePlurks;
			break;
	}
	[[self tableView] reloadData];
}


#pragma mark User Interface

- (void)avatarImageWasClicked:(NSInteger)plurker {
	[userDetailsController setFriend:[[plurkAPI friendDictionary] objectForKey:[plurkAPI nickNameFromUserID:plurker]]];
	[self presentModalViewController:userDetailsController animated:YES];
}

- (void)startComposingWithContent:(NSString *)text qualifier:(NSString *)qualifier {
	WritePlurkTableViewController *controller = [[WritePlurkTableViewController alloc] initWithNibName:@"WritePlurkTableView" bundle:nil];
	UINavigationController *newController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller setCreatingNewPlurk:YES];
	[controller setPlurkAPI:plurkAPI];
	
	if(qualifier && [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Qualifiers" ofType:@"plist"]] containsObject:qualifier]) {
		[controller setInitialQualifier:qualifier];
	}
	if(text) {
		[controller setInitialContent:text];
	}
	
	[self presentModalViewController:newController animated:YES];
	if(text) {
		[controller setInitialContent:text];
	}
	[controller release];
}

- (void)startComposing {
	[self startComposingWithContent:nil qualifier:nil];
}

- (void)userHasSetNewUsername:(NSString *)username andPassword:(NSString *)password {
	NSLog(@"Storing new login details and attempting to log in as %@", username);
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:username forKey:@"plurk_username"];
	[defaults setObject:password forKey:@"plurk_password"];
	[defaults synchronize];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[plurkAPI loginUser:username withPassword:password delegate:self];
}



// FileDownloader
- (void)fileDownloadDidComplete:(NSString *)file {
	UIImage *img = [UIImage imageWithContentsOfFile:file];
	int w = img.size.width;
	int h = img.size.height;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
	
	CGContextBeginPath(context);
	addRoundedRectToPath(context, CGRectMake(0, 0, w, h), 10, 10);
	CGContextClosePath(context);
	CGContextClip(context);
	
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	//[img release];
	
	UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
	NSData *imageData = UIImagePNGRepresentation(newImage);
	[imageData writeToFile:file atomically:YES];
	
	// Get the ID we're looking for.
	NSInteger ourID = [[file stringByReplacingOccurrencesOfRegex:@"^.*?([0-9]+)\\.[a-z]{3,4}$" withString:@"$1"] integerValue];
	
	// Cache it.
	[[ProfileImageCache mainCache] cacheImage:newImage forUser:ourID];
	
	// Fill it into any currently visible cells.
	NSArray *cells = [[self tableView] visibleCells];
	for(PlurkTableViewCell *cell in cells) {
		// We might get the "Load more plurks" cell, so check for that first (or we'll crash)
		if([cell respondsToSelector:@selector(ownerID)] && [cell ownerID] == ourID) {
			[[cell imageButton] setImage:newImage forState:UIControlStateNormal];
		}
	}
	NSLog(@"Downloaded image for plurker %d", ourID);
}

#pragma mark UIViewController

- (void)viewDidLoad {
	NSLog(@"View loaded");
    [super viewDidLoad];
	// Setup
	if(!plurkAPI) {
		canUseTable = YES;
		NSLog(@"Initiating...");
		setupViewController.origin = self;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if([defaults boolForKey:@"ui_paging"]) {
			[[self tableView] setPagingEnabled:YES];
		}
		if([defaults boolForKey:@"ui_richtext"]) {
			plurkTableCellType = @"PlurkRichTextTableViewCell";
		} else {
			plurkTableCellType = @"PlurkPlainTextTableViewCell";
		}
		currentTab = 0;
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(startComposing)] animated:NO];
		plurkAPI = [[PlurkAPI alloc] init];
		self.plurks = [[NSMutableArray alloc] init];
		self.privatePlurks = [[NSMutableArray alloc] init];
		self.unreadPlurks = [[NSMutableArray alloc] init];
		self.currentPlurks = plurks;
		imageCacheDirectory = [[NSString stringWithFormat:@"%@/tmp/avatars", NSHomeDirectory(), nil] retain];
		// Load username/password and log in. Also reset avatar cache switch.
		
		// Wipe the cache if requested.
		if([defaults boolForKey:@"cache_clear"]) {
			NSLog(@"Clearing cache on request.");
			[defaults setBool:NO forKey:@"cache_clear"];
			[[NSFileManager defaultManager] removeItemAtPath:imageCacheDirectory error:NULL];
		}
		
		if(![[NSFileManager defaultManager] fileExistsAtPath:imageCacheDirectory]) {
			if(![[NSFileManager defaultManager] createDirectoryAtPath:imageCacheDirectory attributes:nil]) {
				NSLog(@"Couldn't create imageCacheDirectory %@", imageCacheDirectory);
			}
		}
		
		// Try a quick login first.
		if([plurkAPI quickLoginAs:[defaults stringForKey:@"plurk_username"] withFile:[NSString stringWithFormat:@"%@/Library/login.plist", NSHomeDirectory(), nil]]) {
			NSLog(@"Used quick login.");
			[self plurkLoginDidFinish];
		} else {
			NSLog(@"Performing standard login.");
			// Load specified username and such.
			NSString *username = [defaults stringForKey:@"plurk_username"];
			NSString *password = [defaults stringForKey:@"plurk_password"];
			if([username length] && [password length]) {
				NSLog(@"Attempting to log in as %@.", username);
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
				[plurkAPI loginUser:username withPassword:password delegate:self];
			} else {
				NSLog(@"Asking for login details.");
				[self presentModalViewController:setupViewController animated:YES];
			}
		}

	}
    // Uncomment the following line to add the Edit button to the navigation bar.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"ViewWillAppear - canUseTable = YES");
	canUseTable = YES;
	BOOL done = NO;
	// Dealing with the marked plurk.
	if(selectedRow > -1 && selectedRow < [[self tableView] numberOfRowsInSection:0]) {
		NSIndexPath *selected = [NSIndexPath indexPathForRow:selectedRow inSection:0];
		NSLog(@"SelectedRow known.");
		PlurkTableViewCell *cell = (PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:selected];
		if([cell isKindOfClass:[PlurkTableViewCell class]]) {
			if([[cell plurkDisplayed] isUnread] == 0) {
				NSLog(@"Dealing with read plurk.");
				[[cell plurkDisplayed] setResponsesSeen:[[cell plurkDisplayed] responseCount]];
				[[self tableView] beginUpdates];
				if(currentTab == RootViewTabUnread) {
					[unreadPlurks removeObjectAtIndex:selectedRow];
					[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:selected] withRowAnimation:YES];
				} else {
					[unreadPlurks removeObject:[cell plurkDisplayed]];
				}
				[[self tableView] endUpdates];
			}
			NSLog(@"Marking cell");
			[cell markAsWhateverItShouldBeMarkedAs];
			done = YES;
		} else {
			NSLog(@"Wrong cell type.");
		}
	}
	if(!done && selectedPlurk && [selectedPlurk isUnread] == 0) {
		NSLog(@"selectedPlurk known.");
		[selectedPlurk setResponsesSeen:[selectedPlurk responseCount]];
		NSUInteger index;
		if((index = [unreadPlurks indexOfObject:selectedPlurk]) != NSNotFound) {
			NSLog(@"Removed plurk.");
			[unreadPlurks removeObjectAtIndex:index];
			[[self tableView] reloadData];
		} else {
			NSLog(@"Not an unread plurk, apparently.");
		}
	}
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[unreadPlurks count]];
	NSLog(@"Running super");
    [super viewWillAppear:animated];
	NSLog(@"viewWillAppear done.");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Plurk handling

- (void)removePlurk:(Plurk *)plurk {
	NSInteger index;
	[[self tableView] beginUpdates];
	if((index = [plurks indexOfObject:plurk]) != NSNotFound) {
		[plurks removeObjectAtIndex:index];
		if(currentTab == RootViewTabAll) {
			[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
		}
	}
	if((index = [unreadPlurks indexOfObject:plurk]) != NSNotFound) {
		[unreadPlurks removeObjectAtIndex:index];
		if(currentTab == RootViewTabUnread) {
			[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
		}
	}
	if((index = [privatePlurks indexOfObject:plurk]) != NSNotFound) {
		[privatePlurks removeObjectAtIndex:index];
		if(currentTab == RootViewTabPrivate) {
			[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
		}
	}
	[[self tableView] endUpdates];
}

#pragma mark PlurkAPI

- (void)plurkLoginDidFinish {
	NSLog(@"Creating file: %d", [plurkAPI saveLoginToFile:[NSString stringWithFormat:@"%@/Library/login.plist", NSHomeDirectory(), nil]]);
	if([self modalViewController]) {
		if([[(UINavigationController *)[self modalViewController] topViewController] respondsToSelector:@selector(qualifierCell)]) {
			[[(PlurkQualifierTableViewCell *)[(WritePlurkTableViewController *)[(UINavigationController *)[self modalViewController] topViewController] qualifierCell] name] setText:[[[plurkAPI friendDictionary] objectForKey:[plurkAPI userName]] displayName]];
		}
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	allRequest = [plurkAPI requestPlurksWithDelegate:self];
};

- (void)plurkLoginDidFail {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You couldn't be logged in to Plurk. Please try an alternative username and password." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	// We do this because things go horribly wrong if it's still animating out when we ask it to animate it in.
	// It's equivilent to [self presentModalViewController:setupViewController animated:YES], but delayed by 0.25 seconds.
	NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(presentModalViewController:animated:)]];
	[invoke setSelector:@selector(presentModalViewController:animated:)];
	[invoke setTarget:self];
	[invoke setArgument:&setupViewController atIndex:2];
	BOOL yes = YES;
	[invoke setArgument:&yes atIndex:3];
	[NSTimer scheduledTimerWithTimeInterval:0.25 invocation:invoke repeats:NO];
}

- (void)connection:(NSURLConnection *)connection receivedNewPlurks:(NSArray *)newPlurks {
	if(connection == allRequest && [plurks count] == 0) {
		privateRequest = [[plurkAPI requestPlurksStartingFrom:nil endingAt:([privatePlurks count] ? [[privatePlurks objectAtIndex:0] posted] : nil) onlyPrivate:YES delegate:self] retain];
		unreadRequest = [[plurkAPI requestUnreadPlurksWithDelegate:self] retain];
		NSInteger interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"poll_interval"];
		if(interval == 0) interval = 60;
		NSLog(@"Poll interval: %d", interval);
		if(interval > 0) {
			[plurkAPI runPeriodicPollWithInterval:interval delegate:self];
		}
	}
	if([plurkAPI runningRequests] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	NSLog(@"Beginning updates.");
	NSLog(@"Received %d new plurks", [newPlurks count]);
	if(canUseTable) [[self tableView] beginUpdates];
	for(Plurk *plurk in newPlurks) {
		NSLog(@"%@ %@ %@", [plurk ownerDisplayName], [plurk qualifier], [plurk contentRaw]);
		NSUInteger index = [currentPlurks indexOfObject:plurk];
		if(index != NSNotFound) {
			NSLog(@"Found old plurk %d", [plurk plurkID]);
			Plurk *oldPlurk = [currentPlurks objectAtIndex:index];
			NSLog(@"Updating old plurk %d", [plurk plurkID]);
			oldPlurk.responseCount = [plurk responseCount];
			oldPlurk.responsesSeen = [plurk responsesSeen];
			oldPlurk.isUnread = [plurk isUnread];
			oldPlurk.content = [plurk content];
			oldPlurk.contentRaw = [plurk contentRaw];
			plurk = nil;
			plurk = oldPlurk;
			if(canUseTable) {
				PlurkTableViewCell *cell = nil;
				if(currentTab == RootViewTabAll) {
					cell = (PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
				} else if(currentTab == RootViewTabPrivate) {
					NSInteger privateIndex = [privatePlurks indexOfObject:oldPlurk];
					if(privateIndex != NSNotFound) {
						cell = (PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:privateIndex inSection:0]];
					}
				}
				[cell markAsWhateverItShouldBeMarkedAs];
				[cell renderPlurkText];
			}
		}
		if([[plurk limitedTo] count] > 0) {
			if([privatePlurks containsObject:plurk]) continue;
			NSUInteger index;
			if([plurk isUnread] == 1 && (index = [unreadPlurks indexOfObject:plurk]) != NSNotFound) {
				plurk = [unreadPlurks objectAtIndex:index];
				NSLog(@"Using unreadPlurks instead of privatePlurks for plurk %d from %@", [plurk plurkID], [plurkAPI nickNameFromUserID:[plurk ownerID]]);
			} else if((index = [plurks indexOfObject:plurk]) != NSNotFound) {
				plurk = [plurks objectAtIndex:index];
				NSLog(@"Using plurks instead of privatePlurks for plurk %d from %@", [plurk plurkID], [plurkAPI nickNameFromUserID:[plurk ownerID]]);
			}
			[plurk retain];
			// Find the right instertion position.
			if([plurk plurkID] < [[privatePlurks lastObject] plurkID]) {
				index = [privatePlurks count];
			} else if([privatePlurks count] == 0 || [plurk plurkID] > [[privatePlurks objectAtIndex:0] plurkID]) {
				index = 0;
			} else {
				for(index = 0; index < [privatePlurks count] && [plurk plurkID] < [[privatePlurks objectAtIndex:index] plurkID]; ++index);
			}
			if(currentTab == RootViewTabPrivate && index <= selectedRow) {
				++selectedRow;
			}
			[privatePlurks insertObject:plurk atIndex:index];
			if(currentTab == RootViewTabPrivate && canUseTable) [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
		}
		if([plurk isUnread] == 1) {
			if([unreadPlurks containsObject:plurk]) continue;
			NSUInteger index;
			if([plurk limitedTo] > 0 && (index = [privatePlurks indexOfObject:plurk]) != NSNotFound) {
				plurk = [privatePlurks objectAtIndex:index];
				NSLog(@"Using privatePlurks instead of unreadPlurks for plurk %d from %@", [plurk plurkID], [plurkAPI nickNameFromUserID:[plurk ownerID]]);
			} else if((index = [plurks indexOfObject:plurk]) != NSNotFound) {
				plurk = [plurks objectAtIndex:index];
				NSLog(@"Using plurks instead of unreadPlurks for plurk %d from %@", [plurk plurkID], [plurkAPI nickNameFromUserID:[plurk ownerID]]);
			}
			
			[plurk retain];
			if([plurk plurkID] < [[unreadPlurks lastObject] plurkID]) {
				index = [unreadPlurks count];
			} else if([unreadPlurks count] == 0 || [plurk plurkID] > [[unreadPlurks objectAtIndex:0] plurkID]) {
				index = 0;
			} else {
				for(index = 0; index < [unreadPlurks count] && [plurk plurkID] < [[unreadPlurks objectAtIndex:index] plurkID]; ++index);
			}
			
			if(currentTab == RootViewTabUnread && index <= selectedRow) {
				++selectedRow;
			}
			[unreadPlurks insertObject:plurk atIndex:index];
			if(currentTab == RootViewTabUnread && canUseTable) [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
		}
		if((connection != nil && connection == allRequest) || ([[plurks lastObject] plurkID] < [plurk plurkID])) {
			if([[plurks lastObject] isEqual:plurk]) continue;
			if([plurks containsObject:plurk]) continue;
			if([plurk limitedTo] > 0 && (index = [privatePlurks indexOfObject:plurk]) != NSNotFound) {
				plurk = [privatePlurks objectAtIndex:index];
				NSLog(@"Using privatePlurks instead of plurks for plurk %d from %@", [plurk plurkID], [plurk ownerDisplayName]);
			} else if([plurk isUnread] == 1 && (index = [unreadPlurks indexOfObject:plurk]) != NSNotFound) {
				plurk = [unreadPlurks objectAtIndex:index];
				NSLog(@"Using unreadPlurks instead of plurks for plurk %d from %@", [plurk plurkID], [plurk ownerDisplayName]);
			}
			
			[plurk retain];
			if([plurk plurkID] < [[plurks lastObject] plurkID]) {
				index = [plurks count];
			} else if([plurks count] == 0 || [plurk plurkID] > [[plurks objectAtIndex:0] plurkID]) {
				index = 0;
			} else {
				for(index = 0; index < [plurks count] && [plurk plurkID] < [[plurks objectAtIndex:index] plurkID]; ++index);
			}
			if(currentTab == RootViewTabAll && index <= selectedRow) {
				++selectedRow;
			}
			[plurks insertObject:plurk atIndex:index];
			if(currentTab == RootViewTabAll && canUseTable) [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
		}
	}
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[unreadPlurks count]];
	if(connection == allRequest && canUseTable) {
		allRequest = nil;
		NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:([[self tableView] numberOfRowsInSection:0] - 1) inSection:0];
		UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:lastIndex];
		if([cell respondsToSelector:@selector(spinner)]) {
			[[(LoadMorePlurksCell *)cell spinner] stopAnimating];
		}
	}
	else if(connection == privateRequest) {
		[privateRequest release];
		privateRequest = nil;
	}
	else if(connection == unreadRequest) {
		[unreadRequest release];
		unreadRequest = nil;
	} else if(connection == allRequest) {
		[allRequest release];
		allRequest = nil;
	}
	NSLog(@"Ending updates.");
	if(canUseTable) {
		[[self tableView] endUpdates];
		[[self tableView] setNeedsDisplay];
	}
}

- (void)receivedPlurkResponsePoll:(NSArray *)newResponses {
	NSMutableArray *toFetch = [[NSMutableArray alloc] init];
	for(NSDictionary *dict in newResponses) {
		Plurk *plurk = [[Plurk alloc] init];
		[plurk setPlurkID:[[dict objectForKey:@"plurk_id"] integerValue]];
		Plurk *realPlurk;
		NSInteger index;
		BOOL tryUnread = YES;
		BOOL tryPrivate = YES;
		BOOL requiresSourceUpdate = YES;
		BOOL isNotInUnread = YES;
		if((index = [plurks indexOfObject:plurk]) != NSNotFound) {
			realPlurk = [plurks objectAtIndex:index];
			[realPlurk setResponseCount:[[dict objectForKey:@"response_count"] integerValue]];
			[realPlurk setIsUnread:1];
			requiresSourceUpdate = NO;
			if(currentTab == RootViewTabAll) {
				tryUnread = NO;
				tryPrivate = NO;
				if(canUseTable) [(PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] markAsWhateverItShouldBeMarkedAs];
			}
		}
		if((index = [unreadPlurks indexOfObject:plurk]) != NSNotFound) {
			isNotInUnread = NO;
			if(tryUnread) {
				if(requiresSourceUpdate) {
					realPlurk = [unreadPlurks objectAtIndex:index];
					[realPlurk setResponseCount:[[dict objectForKey:@"response_count"] integerValue]];
					[realPlurk setIsUnread:1];
					requiresSourceUpdate = NO;
				}
				if(currentTab == RootViewTabUnread) {
					tryPrivate = NO;
					if(canUseTable) [(PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] markAsWhateverItShouldBeMarkedAs];
				}
			}
		}
		if(tryPrivate && (index = [privatePlurks indexOfObject:plurk]) != NSNotFound) {
			if(requiresSourceUpdate) {
				realPlurk = [privatePlurks objectAtIndex:index];
				[realPlurk setResponseCount:[[dict objectForKey:@"response_count"] integerValue]];
				[realPlurk setIsUnread:1];
				requiresSourceUpdate = NO;
			}
			if(currentTab == RootViewTabPrivate) {
				if(canUseTable) [(PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] markAsWhateverItShouldBeMarkedAs];
			}
		}
		if(requiresSourceUpdate) {
			[toFetch addObject:[dict objectForKey:@"plurk_id"]];
		} else if(isNotInUnread) {
			NSInteger index;
			if([realPlurk plurkID] < [[unreadPlurks lastObject] plurkID]) {
				index = [unreadPlurks count];
			} else {
				for(index = 0; index < [unreadPlurks count] && [realPlurk plurkID] < [[unreadPlurks objectAtIndex:index] plurkID]; ++index);
				[unreadPlurks insertObject:realPlurk atIndex:index];
				if(currentTab == RootViewTabUnread) {
					if(canUseTable) NSLog(@"%d rows in table, %d plurks", [[self tableView] numberOfRowsInSection:0], [unreadPlurks count]);
					NSLog(@"Inserting row.");
					if(canUseTable) [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
				}
				if(currentTab == RootViewTabUnread && index <= selectedRow) {
					++selectedRow;
				}
			}
		}
	}
	if([toFetch count] > 0) {
		[plurkAPI requestPlurksByIDs:toFetch delegate:self];
	}
}

- (void)plurkHTTPRequestAborted:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"API failure"
						  message:[NSString stringWithFormat:@"An attempt to load information from Plurk failed:\n\n%@ (%d)", [error localizedDescription], [error code], nil]
						  delegate:nil 
						  cancelButtonTitle:@"Dismiss" 
						  otherButtonTitles:nil
	];
	[alert show];
	[alert release];
}

/*
// Override to support editing the list
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
     //   [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support conditional editing of the list
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if(currentTab == RootViewTabAll && [[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] == @"LoadMorePlurksCell") {
		return NO;
	}
	PlurkTableViewCell *cell = (PlurkTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	return ([cell plurkDisplayed] && [[cell plurkDisplayed] ownerID] == [plurkAPI userID]);
}
*/


/*
// Override to support rearranging the list
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the list
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/


#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
	canUseTable = NO;
	NSLog(@"Can't use table.");
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	NSLog(@"WARNING: didReceiveLowMemoryWarning. Removing images in memory.");
	[[ProfileImageCache mainCache] emptyCache];
}

- (void)dealloc {
	[plurks release];
	[plurkAPI release];
	[setupViewController release];
	[userDetailsController release];
    [super dealloc];
}

@end

