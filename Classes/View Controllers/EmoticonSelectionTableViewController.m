//
//  EmoticonSelectionTableViewController.m
//  iPlurk
//
//  Created on 06/02/2009.
//  Copyright 2009 AjaxLife Developments. All rights reserved.
//

#import "EmoticonSelectionTableViewController.h"


@implementation EmoticonSelectionTableViewController
@synthesize table;
@synthesize delegate, action;

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
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([emoticons count] / 5);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EmoticonCell";
	[tableView numberOfRowsInSection:0];
    EmoticonTableViewCell *cell = (EmoticonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[EmoticonTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		[cell setDelegate:delegate];
		[cell setAction:action];
		[cell setImages:emoticonImages];
    }
    
    // Set up the cell...
	NSRange range = NSMakeRange([indexPath row] * 5, 5);
	if([emoticons count] <= range.location + 5) {
		range.length = [emoticons count] - range.location;
	}
	
	[cell setEmoticons:[emoticons subarrayWithRange:range]];
	
    return cell;
}

- (void)doSetup {
	NSLog(@"Doing setup.");
	NSDictionary *allEmoticons = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EmoticonsBinary" ofType:@"plist"]];
	emoticons = [[NSMutableArray arrayWithArray:[allEmoticons objectForKey:@"basic"]] retain];
	float karma = [[[PlurkAPI sharedAPI] currentUser] karma];
	if(karma > 25.0) {
		[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"silver"]];
		if(karma > 50.0) {
			[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"gold"]];
			if(karma > 81.0) {
				[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"platinum_2"]];
			}
		}
	}
	if([[PlurkAPI sharedAPI] hasTenFriends]) {
		[emoticons addObjectsFromArray:[allEmoticons objectForKey:@"platinum"]];
	}
	allEmoticons = nil;
	emoticonImages = [[[NSMutableDictionary alloc] init] retain];
	NSString *emoticonPath = [NSString stringWithFormat:@"%@/statics/%%@", [[NSBundle mainBundle] resourcePath], nil];
	for(NSDictionary *dict in emoticons) {
		UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:emoticonPath, [dict objectForKey:@"url"], nil]];
		[image size];
		[emoticonImages setObject:image forKey:[dict objectForKey:@"name"]];
	}
	
	NSLog(@"Did setup: %d emoticons", [emoticons count]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[emoticons release];
	[emoticonImages release];
    [super dealloc];
}


@end

