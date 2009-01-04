//
//  GenericPlurkTimelineViewController.h
//  iPlurk
//
//  Created on 07/12/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "GenericPlurkTimelineViewController.h"


@implementation GenericPlurkTimelineViewController
@synthesize timelineOwner;
@synthesize timelineToLoad;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if(!plurks) {
		plurks = [[NSMutableArray alloc] init];
		downloadStarted = NO;
		if([plurks count] == 0) {
			if(timelineOwner) {
				[[self navigationItem] setTitle:[timelineOwner displayName]];
				apiConnection = [[[PlurkAPI sharedAPI] requestPlurksFrom:[timelineOwner uid] startingFrom:nil endingAt:nil onlyPrivate:NO delegate:self] retain];
				connection = nil;
			} else if(timelineToLoad) {
				//NSLog(@"Loading from http://www.plurk.com/%@", timelineToLoad);
				[[self navigationItem] setTitle:timelineToLoad];
				receivedData = [[NSMutableData alloc] init];
				NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.plurk.com/%@", timelineToLoad, nil]]];
				connection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
				apiConnection = nil;
				[request release];
			}

			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/


- (void)viewDidDisappear:(BOOL)animated {
	[connection cancel];
	if(apiConnection != nil) {
		[[PlurkAPI sharedAPI] cancelConnection:apiConnection];
	}
	[super viewDidDisappear:animated];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	//NSLog(@"Loading fail.");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't open timeline" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	// Two second delay mess, again.
	NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[[self navigationController] methodSignatureForSelector:@selector(popViewControllerAnimated:)]];
	[invoke setTarget:[self navigationController]];
	[invoke setSelector:@selector(popViewControllerAnimated:)];
	BOOL yes = YES;
	[invoke setArgument:&yes atIndex:2];
	[invoke performSelector:@selector(invoke) withObject:nil afterDelay:2];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
	//NSLog(@"Received more data.");
	[receivedData appendData:data];
	
	// Check if we have enough.
	NSString *string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	//NSLog(@"Received data: %@", string);
	NSRange range = [string rangeOfRegex:@"var SETTINGS = (\\{.+?\\});" capture:1];
	if(range.location != NSNotFound) {
		NSDictionary *data = [[string substringWithRange:range] JSONValue];
		if(data) {
			[connection cancel];
			timelineOwner = [[[PlurkFriend alloc] init] retain];
			[timelineOwner setUid:[[data objectForKey:@"user_id"] integerValue]];
			[timelineOwner setNickName:timelineToLoad];
			[timelineOwner setDisplayName:timelineToLoad];
			//NSLog(@"Got user_id: %d", [timelineOwner uid]);
			apiConnection = [[PlurkAPI sharedAPI] requestPlurksFrom:[timelineOwner uid] startingFrom:nil endingAt:nil onlyPrivate:NO delegate:self];
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
	[receivedData setLength:0];
	if(!timelineOwner) {
		NSError *error = [NSError errorWithDomain:@"iPlurk" code:404 userInfo:[NSDictionary dictionaryWithObject:@"Plurker Not Found" forKey:NSLocalizedDescriptionKey]];
		[self connection:theConnection didFailWithError:error];
	}
}

#pragma mark PlurkAPI methods

- (void)connection:(NSURLConnection *)connection receivedNewPlurks:(NSArray *)newPlurks {
	[plurks addObjectsFromArray:newPlurks];
	[[self tableView] reloadData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)fileDownloadDidComplete:(NSString *)file {
	[FileDownloader addRoundedCorners:file];
	
	// Get the ID we're looking for.
	NSInteger ourID = [[file stringByReplacingOccurrencesOfRegex:@"^.*?([0-9]+)\\.[a-z]{3,4}$" withString:@"$1"] integerValue];
	
	// Cache it.
	[[ProfileImageCache mainCache] cacheImage:[UIImage imageWithContentsOfFile:file] forUser:ourID];
	
	// Fill it into any currently visible cells.
	NSArray *cells = [[self tableView] visibleCells];
	for(PlurkTableViewCell *cell in cells) {
		[[cell imageButton] setImage:[[ProfileImageCache mainCache] retrieveImageForUser:ourID] forState:UIControlStateNormal];
	}
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [plurks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *plurkTableCellType;
	if(!plurkTableCellType) {
		plurkTableCellType = ([[NSUserDefaults standardUserDefaults] boolForKey:@"ui_richtext"] ? @"PlurkRichTextTableViewCell" : @"PlurkPlainTextTableViewCell");
	}
	// Produce a cell from somewhere.
    PlurkTableViewCell *cell = nil;
	cell = (PlurkTableViewCell *)[tableView dequeueReusableCellWithIdentifier:plurkTableCellType];
    if (cell == nil) {
        UIViewController *viewController = [[UIViewController alloc] initWithNibName:plurkTableCellType bundle:nil];
		cell = (PlurkTableViewCell *)[viewController view];
		[viewController release];
    }
	
	// Find the right plurk
	Plurk *plurk = [plurks objectAtIndex:[indexPath row]];
	PlurkFriend *friend = [[[PlurkAPI sharedAPI] friendDictionary] objectForKey:[[PlurkAPI sharedAPI] nickNameFromUserID:[plurk ownerID]]];
	
	// Display text
	[cell displayPlurk:plurk];
	
	// Try loading a cached image, if we want one at all.
	if([friend hasProfileImage]) {
		UIImage *avatar = nil;
		avatar = [[ProfileImageCache mainCache] retrieveImageForUser:[plurk ownerID]];
		if(!avatar) {
			NSString *pathToImage = [PlurkFormatting avatarPathForUserID:[plurk ownerID]];
			//NSLog(@"Looking for image in %@", pathToImage);
			if([[NSFileManager defaultManager] fileExistsAtPath:pathToImage]) {
				avatar = [UIImage imageWithContentsOfFile:pathToImage];
				[[ProfileImageCache mainCache] cacheImage:avatar forUser:[plurk ownerID]];
			}
			if(!avatar && !downloadStarted) {
				// No cached image. Go get it.
				NSURL *avatarUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://avatars.plurk.com/%d-medium.gif", [plurk ownerID], nil]];
				FileDownloader *downloader = [[FileDownloader alloc] initFromURL:avatarUrl toFile:pathToImage notify:self];
				[downloader release];
				downloadStarted = YES;
			}
		}
		if(avatar) {
			[[cell imageButton] setImage:[avatar retain] forState:UIControlStateNormal];
		}
	}
	
	// Set the disclosure indicator, since it seems to like vanishing.
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	// Link up the button
	cell.delegate = self;
	
	//[indexPath release];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RootViewController *controller = [[[self navigationController] viewControllers] objectAtIndex:0];
	[controller displayPlurk:[plurks objectAtIndex:[indexPath row]]];
}



- (void)dealloc {
	[connection cancel];
	[connection release];
	[timelineOwner release];
	[plurks release];
	[timelineToLoad release];
	[receivedData release];
	[apiConnection release];
    [super dealloc];
}


@end

