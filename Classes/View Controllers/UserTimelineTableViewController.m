//
//  RootViewController.m
//  iPlurk
//
//  Created on 08/10/2008.
//  Copyright AjaxLife Developments 2008. All rights reserved.
//

#import "UserTimelineTableViewController.h"


@implementation UserTimelineTableViewController
@synthesize setupViewController;
@synthesize tabs;

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(currentTab == RootViewTabAll && [plurks count] > 0 && !showingUnread) {
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
	PlurkFriend *friend = [[[PlurkAPI sharedAPI] friendDictionary] objectForKey:[[PlurkAPI sharedAPI] nickNameFromUserID:[plurk ownerID]]];
	
	// Display text
	[cell displayPlurk:plurk];
	
	// Mark is unread if it's unread.
	if([plurk isUnread] == 1) {
		[cell markAsUnread];
	}
	
	// Try loading a cached image, if we want one at all.
	if([friend hasProfileImage]) {
		UIImage *avatar = nil;
		NSLog(@"Trying cache.");
		avatar = [[ProfileImageCache mainCache] retrieveImageForUser:[plurk ownerID] avatarNumber:[[friend avatar] integerValue]];
		if(!avatar && ![filesDownloading objectForKey:[NSNumber numberWithInteger:[plurk ownerID]]]) {
			NSLog(@"Cache failed.");
			// No cached image. Go get it.
			NSURL *avatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://avatars.plurk.com/%d-medium%@.gif", [plurk ownerID], [friend avatar], nil]];
			FileDownloader *downloader = [[FileDownloader alloc] initFromURL:avatarUrl withIdentifier:[NSNumber numberWithInteger:[plurk ownerID]] delegate:self];
			[downloader release];
			[filesDownloading setObject:[friend avatar] forKey:[NSNumber numberWithInteger:[plurk ownerID]]];
		} else {
			NSLog(@"Cache succeeded.");
			[[cell imageButton] setImage:[avatar retain] forState:UIControlStateNormal];
		}
	} else {
		[[cell imageButton] setImage:[UIImage imageNamed:@"DefaultAvatarImage.png"] forState:UIControlStateNormal];
	}
	
	// Set the disclosure indicator, since it seems to like vanishing.
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	// Link up the button
	cell.delegate = self;
	
	//[indexPath release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic -- create and push a new view controller
	if([indexPath row] >= [currentPlurks count]) {
		if(!allRequest) {
			allRequest = [[PlurkAPI sharedAPI] requestPlurksStartingFrom:[[[currentPlurks lastObject] posted] addTimeInterval:1.0] endingAt:nil onlyPrivate:NO delegate:self];
			[[(LoadMorePlurksCell *)[tableView cellForRowAtIndexPath:indexPath] spinner] startAnimating];
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		[selectedPlurk release];
		selectedRow = [indexPath row];
		selectedPlurk = [[currentPlurks objectAtIndex:selectedRow] retain];
		[self displayPlurk:selectedPlurk];
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		//[(PlurkTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] markAsRead];
	}
}

#pragma mark Interface Builder

- (IBAction)tabHasChanged {
	//NSLog(@"TabHasChanged.");
	currentTab = (RootViewTab)[tabs selectedSegmentIndex];
	if(currentTab == UISegmentedControlNoSegment) currentTab = RootViewTabAll;
	switch (currentTab) {
		case RootViewTabAll:
			currentPlurks = plurks;
			break;
		case RootViewTabPrivate:
			currentPlurks = privatePlurks;
			break;
		case RootViewTabMine:
			currentPlurks = myPlurks;
			break;
		case RootViewTabReplied:
			currentPlurks = repliedPlurks;
			break;
	}
	if(showingUnread) {
		if(currentTab == RootViewTabAll) {
			currentPlurks = unreadPlurks;
		} else {
			NSMutableArray *actualPlurks = [[NSMutableArray alloc] init];
			for(Plurk *plurk in currentPlurks) {
				if([plurk isUnread]) {
					[actualPlurks addObject:plurk];
				}
			}
			currentPlurks = actualPlurks;
		}
	}
	
	[[self tableView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
	[[self tableView] reloadData];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) { // Compose
		[self startComposing];
	} else if(buttonIndex == 0) { // Mark all as read
		NSMutableArray *plurksToMark = [[NSMutableArray alloc] init];
		for(Plurk *plurk in unreadPlurks) {
			[plurksToMark addObject:[NSNumber numberWithInteger:[plurk plurkID]]];
			[plurk setIsUnread:NO];
			[plurk setResponsesSeen:[plurk responseCount]];
		}
		[[PlurkAPI sharedAPI] markPlurksAsRead:plurksToMark];
		[unreadPlurks removeAllObjects];
		
		if(showSpringboardBadge) [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
		[[self tableView] reloadData];
	}
}

#pragma mark User Interface

- (void)confirmMarkAllAsRead {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mark All As Read", @"Compose New Plurk", nil];
	[sheet showInView:[self view]];
	[sheet release];
}

- (void)displayPlurkWithBase36ID:(NSString *)plurkID {
	NSInteger number = 0;
	NSInteger multiplier = 1;
	static NSString* basechars = @"0123456789abcdefghijklmnopqrstuvwxyz";
	for(NSInteger i = [plurkID length] - 1; i >= 0; --i) {
		NSInteger mantissa = [basechars rangeOfString:[plurkID substringWithRange:NSMakeRange(i, 1)]].location;
		if(mantissa == NSNotFound) break;
		number += mantissa * multiplier;
		multiplier *= 36;
	}
	//NSLog(@"Base 36 %@ converted to %d", plurkID, number);
	[self displayPlurkWithID:number];
}

- (void)displayPlurkWithID:(NSInteger)plurkID {
	PlurkResponsesViewController *controller = [[PlurkResponsesViewController alloc] initWithNibName:@"PlurkResponsesView" bundle:nil];
	controller.plurkIDToLoad = plurkID;
	controller.delegate = self;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)displayPlurk:(Plurk *)plurk {
	PlurkResponsesViewController *controller = [[PlurkResponsesViewController alloc] initWithNibName:@"PlurkResponsesView" bundle:nil];
	controller.firstPlurk = plurk;
	controller.delegate = self;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)displayAlternateTimeline:(NSString *)timeline {
	if([timeline caseInsensitiveCompare:[[PlurkAPI sharedAPI] userName]] == NSOrderedSame) return;
	GenericPlurkTimelineViewController *controller = [[GenericPlurkTimelineViewController alloc] initWithNibName:@"GenericPlurkTimelineView" bundle:nil];
	[controller setTimelineToLoad:timeline];
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release];
}

- (void)displayAlternateTimelineForFriend:(PlurkFriend *)friend {
	if([friend uid] == [[PlurkAPI sharedAPI] userID]) return;
	GenericPlurkTimelineViewController *controller = [[GenericPlurkTimelineViewController alloc] initWithNibName:@"GenericPlurkTimelineView" bundle:nil];
	[controller setTimelineOwner:friend];
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release];
}

- (void)startComposingWithContent:(NSString *)text qualifier:(NSString *)qualifier {
	WritePlurkTableViewController *controller = [[WritePlurkTableViewController alloc] initWithNibName:@"WritePlurkTableView" bundle:nil];
	UINavigationController *newController = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller setCreatingNewPlurk:YES];
	
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

- (void)toggleUnread {
	showingUnread = !showingUnread;
	[[[self navigationItem] leftBarButtonItem] setStyle:(showingUnread ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain)];
	if(showingUnread) {
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(confirmMarkAllAsRead)] animated:YES];
	} else {
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(startComposing)] animated:YES];
	}
	[self tabHasChanged];
}

- (void)userHasSetNewUsername:(NSString *)username andPassword:(NSString *)password {
	//NSLog(@"Storing new login details and attempting to log in as %@", username);
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:username forKey:@"plurk_username"];
	[defaults setObject:password forKey:@"plurk_password"];
	[defaults synchronize];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[[PlurkAPI sharedAPI] loginUser:username withPassword:password delegate:self];
}



// FileDownloader
- (void)fileDownloadWithIdentifier:(NSNumber *)identifier completedWithData:(NSData *)data {
	//NSLog(@"Download of %@ complete.", file);
	UIImage *img = [FileDownloader addRoundedCorners:[UIImage imageWithData:data]];
	
	// Get the ID we're looking for.
	NSInteger ourID = [identifier integerValue];
	NSInteger avatar = [[filesDownloading objectForKey:identifier] integerValue];
	
	// Cache it.
	[[ProfileImageCache mainCache] cacheImage:img forUser:ourID avatarNumber:avatar];
	
	// Remove it from the downloading list.
	[filesDownloading removeObjectForKey:identifier];
	
	// Fill it into any currently visible cells.
	NSArray *cells = [[self tableView] visibleCells];
	for(PlurkTableViewCell *cell in cells) {
		// We might get the "Load more plurks" cell, so check for that first (or we'll crash)
		if([cell respondsToSelector:@selector(ownerID)] && [cell ownerID] == ourID) {
			[[cell imageButton] setImage:img forState:UIControlStateNormal];
			[cell setNeedsLayout];
			//NSLog(@"Displayed image for %d", ourID);
		}
	}
	//NSLog(@"Downloaded image for plurker %d", ourID);
}

- (void)avatarImageWasClicked:(NSInteger)userID {
	PlurkFriend *friend = [[[PlurkAPI sharedAPI] friendDictionary] valueForKey:[[PlurkAPI sharedAPI] nickNameFromUserID:userID]];
	[self displayAlternateTimelineForFriend:friend];
}

- (void)respondedToPlurk:(Plurk *)plurk {
	[self addNewPlurk:plurk toPlurkArray:repliedPlurks usedForTab:RootViewTabReplied];
}

#pragma mark UIViewController

- (void)viewDidLoad {
	//NSLog(@"View loaded");
    [super viewDidLoad];
	[[self tableView] setScrollsToTop:YES];
	// Setup
	if(!filesDownloading) {
		canUseTable = YES;
		//NSLog(@"Initiating...");
		filesDownloading = [[NSMutableDictionary alloc] init];
		setupViewController.origin = self;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		enableUserInterfacePaging = [defaults boolForKey:@"ui_paging"];
		if([defaults boolForKey:@"ui_richtext"]) {
			plurkTableCellType = @"PlurkRichTextTableViewCell";
		} else {
			plurkTableCellType = @"PlurkPlainTextTableViewCell";
		}
		
		NSLog(@"ShowUnreadCount: %@", [defaults stringForKey:@"show_unread_count"]);
		if([[defaults stringForKey:@"show_unread_count"] isEqualToString:@"0"]) {
			showSpringboardBadge = NO;
			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
		} else {
			showSpringboardBadge = YES;
		}
		
		currentTab = 0;
		[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(startComposing)] animated:NO];
		[[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Unread.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleUnread)] animated:NO];
		plurks = [[[NSMutableArray alloc] init] retain];
		privatePlurks = [[[NSMutableArray alloc] init] retain];
		unreadPlurks = [[[NSMutableArray alloc] init] retain];
		myPlurks = [[[NSMutableArray alloc] init] retain];
		repliedPlurks = [[[NSMutableArray alloc] init] retain];
		masterPlurkArray = [[[NSMutableArray alloc] init] retain];
		currentPlurks = plurks;
		// Load username/password and log in. Also reset avatar cache switch.
		
		// Wipe the cache if requested.
		if([defaults boolForKey:@"cache_clear"]) {
			//NSLog(@"Clearing cache on request.");
			[[ProfileImageCache mainCache] purgeDiskCache];
			[defaults setBool:NO forKey:@"cache_clear"];
		}
		
		// Try a quick login first.
		if([[PlurkAPI sharedAPI] quickLoginAs:[defaults stringForKey:@"plurk_username"] withFile:[NSString stringWithFormat:@"%@/Library/login.plist", NSHomeDirectory(), nil]]) {
			//NSLog(@"Used quick login.");
			[self plurkLoginDidFinish];
		} else {
			//NSLog(@"Performing standard login.");
			// Load specified username and such.
			NSString *username = [defaults stringForKey:@"plurk_username"];
			NSString *password = [defaults stringForKey:@"plurk_password"];
			if([username length] && [password length]) {
				//NSLog(@"Attempting to log in as %@.", username);
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
				[[PlurkAPI sharedAPI] loginUser:username withPassword:password delegate:self];
			} else {
				//NSLog(@"Asking for login details.");
				[self presentModalViewController:setupViewController animated:YES];
			}
		}

	}
	
	// We do this here because we have to do it again if we we didReceiveMemoryWarning,
	// and we want to do this *after* finding out if it's enabled once.
	if(enableUserInterfacePaging) {
		[[self tableView] setPagingEnabled:YES];
		[[self tableView] setRowHeight:104];
	}
	
    // Uncomment the following line to add the Edit button to the navigation bar.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	//NSLog(@"ViewWillAppear - canUseTable = YES");
	canUseTable = YES;
	BOOL done = NO;
	// Dealing with the marked plurk.
	if(selectedRow > -1 && selectedRow < [[self tableView] numberOfRowsInSection:0]) {
		NSIndexPath *selected = [NSIndexPath indexPathForRow:selectedRow inSection:0];
		//NSLog(@"SelectedRow known.");
		PlurkTableViewCell *cell = (PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:selected];
		if([cell isKindOfClass:[PlurkTableViewCell class]]) {
			if([[cell plurkDisplayed] isUnread] == 0) {
				//NSLog(@"Dealing with read plurk.");
				[[cell plurkDisplayed] setResponsesSeen:[[cell plurkDisplayed] responseCount]];
				[[self tableView] beginUpdates];
				if(showingUnread) {
					[unreadPlurks removeObjectAtIndex:selectedRow];
					[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:selected] withRowAnimation:YES];
				} else {
					[unreadPlurks removeObject:[cell plurkDisplayed]];
				}
				[[self tableView] endUpdates];
			}
			//NSLog(@"Marking cell");
			[cell markAsWhateverItShouldBeMarkedAs];
			done = YES;
		} else {
			//NSLog(@"Wrong cell type.");
		}
	}
	if(!done && selectedPlurk && [selectedPlurk isUnread] == 0) {
		//NSLog(@"selectedPlurk known.");
		[selectedPlurk setResponsesSeen:[selectedPlurk responseCount]];
		NSUInteger index;
		if((index = [unreadPlurks indexOfObject:selectedPlurk]) != NSNotFound) {
			//NSLog(@"Removed plurk.");
			[unreadPlurks removeObjectAtIndex:index];
			[[self tableView] reloadData];
		} else {
			//NSLog(@"Not an unread plurk, apparently.");
		}
	}
	if(showSpringboardBadge) [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[unreadPlurks count]];
	//NSLog(@"Running super");
    [super viewWillAppear:animated];
	//NSLog(@"viewWillAppear done.");
}

- (void)viewWillDisappear:(BOOL)animated {
	contentOffset = [[self tableView] contentOffset];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	// Restore the scroll level, if we have one (in case the view was unloaded).
	[[self tableView] setContentOffset:contentOffset animated:NO];
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Plurk handling

- (void)removePlurk:(Plurk *)plurk {
	NSUInteger index;
	if((index = [currentPlurks indexOfObject:plurk]) != NSNotFound) {
		[[self tableView] beginUpdates];
		[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
		[currentPlurks removeObjectAtIndex:index];
		[[self tableView] endUpdates];
	}
	if((index = [masterPlurkArray indexOfObject:plurk]) != NSNotFound) {
		[masterPlurkArray removeObjectAtIndex:index];
	}
	if((index = [plurks indexOfObject:plurk]) != NSNotFound) {
		[plurks removeObjectAtIndex:index];
	}
	if((index = [unreadPlurks indexOfObject:plurk]) != NSNotFound) {
		[unreadPlurks removeObjectAtIndex:index];
	}
	if((index = [myPlurks indexOfObject:plurk]) != NSNotFound) {
		[myPlurks removeObjectAtIndex:index];
	}
	if((index = [repliedPlurks indexOfObject:plurk]) != NSNotFound) {
		[repliedPlurks removeObjectAtIndex:index];
	}
}

#pragma mark PlurkAPI

- (void)plurkLoginDidFinish {
	NSLog(@"Creating file: %d", [[PlurkAPI sharedAPI] saveLoginToFile:[NSString stringWithFormat:@"%@/Library/login.plist", NSHomeDirectory(), nil]]);
	// If we started creating a plurk before logging in, e.g. using an iplurk://post URL, fill in the name.
	if([self modalViewController]) {
		if([[(UINavigationController *)[self modalViewController] topViewController] respondsToSelector:@selector(qualifierCell)]) {
			[[(PlurkQualifierTableViewCell *)[(WritePlurkTableViewController *)[(UINavigationController *)[self modalViewController] topViewController] qualifierCell] name] setText:[[[[PlurkAPI sharedAPI] friendDictionary] objectForKey:[[PlurkAPI sharedAPI] userName]] displayName]];
		}
	}
	// If we're meant to be opening a plurk
	if(plurkToLoad > 0) {
		[[PlurkAPI sharedAPI] requestPlurksByIDs:[NSArray arrayWithObject:[NSNumber numberWithInteger:plurkToLoad]] delegate:self];
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	allRequest = [[PlurkAPI sharedAPI] requestPlurksWithDelegate:self];
};

- (void)plurkLoginDidFail {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Please try an alternative username and password." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
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

- (NSUInteger)addNewPlurk:(Plurk *)plurk toPlurkArray:(NSMutableArray *)array usedForTab:(RootViewTab)tab {
	//if([array containsObject:plurk]) return;
	NSUInteger index = 0;
	while(index < [array count] && [[array objectAtIndex:index] plurkID] >= [plurk plurkID]) {
		if([[array objectAtIndex:index] plurkID] == [plurk plurkID]) return -1;
		++index;
	}
	[array insertObject:plurk atIndex:index];
	
	if(canUseTable && currentTab == tab && (!showingUnread || ([plurk isUnread] == 1 && array != plurks))) {
		[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
	}
	return index;
}

- (void)connection:(NSURLConnection *)connection receivedNewPlurks:(NSArray *)newPlurks {
	if([newPlurks count] == 0) return;
	if([plurks count] == 0 && [[[self navigationController] viewControllers] count] > 1) canUseTable = NO;
	if(connection == allRequest && [plurks count] == 0) {
		privateRequest = [[[PlurkAPI sharedAPI] requestPlurksStartingFrom:nil endingAt:[[privatePlurks lastObject] posted] onlyPrivate:YES delegate:self] retain];
		unreadRequest = [[[PlurkAPI sharedAPI] requestUnreadPlurksWithDelegate:self] retain];
		mineRequest = [[[PlurkAPI sharedAPI] requestPlurksFrom:-1 startingFrom:nil endingAt:[[myPlurks lastObject] posted] onlyPrivate:NO onlyResponded:NO onlyMine:YES delegate:self] retain];
		repliedRequest = [[[PlurkAPI sharedAPI] requestPlurksFrom:-1 startingFrom:nil endingAt:nil onlyPrivate:NO onlyResponded:YES onlyMine:NO delegate:self] retain];
		NSInteger interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"poll_interval"];
		if(interval == 0) interval = 60;
		//NSLog(@"Poll interval: %d", interval);
		if(interval > 0) {
			[[PlurkAPI sharedAPI] runPeriodicPollWithInterval:interval delegate:self];
		}
	}
	if([[PlurkAPI sharedAPI] runningRequests] == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	//NSLog(@"Beginning updates.");
	//NSLog(@"Received %d new plurks", [newPlurks count]);
	if(canUseTable) [[self tableView] beginUpdates];
	
	// Check if we'll need to insert an extra row at the end for the "Load more plurks" button.
	// This is necessary because the iPhone 2.2 SDK checks if the number of rows inserted
	// matches the number of rows that appeared, and throws an exception if it doesn't.
	BOOL insertExtraRow = (currentTab == RootViewTabAll && [plurks count] == 0);
	
	for(Plurk *plurk in newPlurks) {
		//NSLog(@"%@ %@ %@", [plurk ownerDisplayName], [plurk qualifier], [plurk contentRaw]);
		NSUInteger index = [currentPlurks indexOfObject:plurk];
		if(index != NSNotFound) {
			//NSLog(@"Found old plurk %d", [plurk plurkID]);
			Plurk *oldPlurk = [currentPlurks objectAtIndex:index];
			//NSLog(@"Updating old plurk %d", [plurk plurkID]);
			oldPlurk.responseCount = [plurk responseCount];
			oldPlurk.responsesSeen = [plurk responsesSeen];
			oldPlurk.isUnread = [plurk isUnread];
			oldPlurk.content = [plurk content];
			oldPlurk.contentRaw = [plurk contentRaw];
			plurk = nil;
			plurk = oldPlurk;
			if(canUseTable) {
				PlurkTableViewCell *cell = nil;
				cell = (PlurkTableViewCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
				[cell markAsWhateverItShouldBeMarkedAs];
				[cell renderPlurkText];
			}
		}
		
		if(![masterPlurkArray containsObject:plurk]) {
			[masterPlurkArray addObject:plurk];
			
			// Check if we need to add to the "All" tab - only if it's the first request,
			// or the plurk is more recent than the oldest plurk we have (to avoid
			// anachronisms)
			if(connection == allRequest || [[plurks lastObject] plurkID] < [plurk plurkID]) {
				[self addNewPlurk:plurk toPlurkArray:plurks usedForTab:RootViewTabAll];
			}
		}
		
		plurk = [masterPlurkArray objectAtIndex:[masterPlurkArray indexOfObject:plurk]];
		
		// Do the same for private plurks, but don't check for anachronisms.
		if([[plurk limitedTo] count] > 0) {
			[self addNewPlurk:plurk toPlurkArray:privatePlurks usedForTab:RootViewTabPrivate];
		}
		
		// And my plurks
		if([plurk ownerID] == [[PlurkAPI sharedAPI] userID] && (connection == mineRequest || [[plurks lastObject] plurkID] < [plurk plurkID])) {
			[self addNewPlurk:plurk toPlurkArray:myPlurks usedForTab:RootViewTabMine];
		}
		
		// And replied plurks... how do we know which ones those are, again?
		if(connection == repliedRequest) {
			[self addNewPlurk:plurk toPlurkArray:repliedPlurks usedForTab:RootViewTabReplied];
		}
		
		// Unread plurks.
		if([plurk isUnread] == 1) {
			[self addNewPlurk:plurk toPlurkArray:unreadPlurks usedForTab:RootViewTabNone];
		}
	}
	
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
	} else if(connection == mineRequest) {
		[mineRequest release];
		mineRequest = nil;
	} else if(connection == repliedRequest) {
		[repliedRequest release];
		repliedRequest = nil;
	}
	if(canUseTable) {
		//NSLog(@"Ending updates.");
		if(insertExtraRow) {
			//NSLog(@"Inserting an extra row to compensate for 'show more plurks'.");
			[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[plurks count] inSection:0]] withRowAnimation:YES];
		}
		[[self tableView] endUpdates];
		[[self tableView] setNeedsDisplay];
	}
	if(showSpringboardBadge) [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[unreadPlurks count]];
}

- (void)receivedPlurkResponsePoll:(NSArray *)newResponses {
	NSMutableArray *toFetch = [[NSMutableArray alloc] init];
	for(NSDictionary *dict in newResponses) {
		Plurk *plurk = [[Plurk alloc] init];
		[plurk setPlurkID:[[dict objectForKey:@"plurk_id"] integerValue]];
		Plurk *realPlurk;
		NSUInteger index;
		if((index = [masterPlurkArray indexOfObject:plurk]) == NSNotFound) {
			[toFetch addObject:[dict objectForKey:@"plurk_id"]];
		} else {
			realPlurk = [masterPlurkArray objectAtIndex:index];
			[realPlurk setResponseCount:[[dict objectForKey:@"response_count"] integerValue]];
			[realPlurk setIsUnread:1];
			if([unreadPlurks indexOfObject:realPlurk] == NSNotFound) {
				if([realPlurk plurkID] < [[unreadPlurks lastObject] plurkID]) {
					index = [unreadPlurks count];
				} else {
					for(index = 0; index < [unreadPlurks count] && [realPlurk plurkID] < [[unreadPlurks objectAtIndex:index] plurkID]; ++index);
					[unreadPlurks insertObject:realPlurk atIndex:index];
					if(showingUnread && currentTab == RootViewTabAll) {
						if(canUseTable) [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
					}
					if(showingUnread && index <= selectedRow) {
						++selectedRow;
					}
				}
			}
		}
	}
	if([toFetch count] > 0) {
		[[PlurkAPI sharedAPI] requestPlurksByIDs:toFetch delegate:self];
	}
}

- (void)plurkHTTPRequestAborted:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Couldn't connect to Plurk"
						  message:[error localizedDescription]
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
	return ([cell plurkDisplayed] && [[cell plurkDisplayed] ownerID] == [[PlurkAPI sharedAPI] userID]);
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
	//NSLog(@"Can't use table.");
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	//NSLog(@"WARNING: didReceiveLowMemoryWarning. Removing images in memory.");
	[[ProfileImageCache mainCache] emptyCache];
}

- (void)dealloc {
	[plurks release];
	[setupViewController release];
	[filesDownloading release];
    [super dealloc];
}

@end

