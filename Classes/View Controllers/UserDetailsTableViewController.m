//
//  UserDetailsTableViewController.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "UserDetailsTableViewController.h"


@implementation UserDetailsTableViewController
@synthesize friend;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)setPlurkFriend:(PlurkFriend *)newFriend {
	friend = newFriend;
	NSLog(@"Set friend to %d, %d", [newFriend uid], [friend uid]);
	[[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? 1 : 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if([indexPath section] == 1) {
		
		ButtonTableViewCell *cell = (ButtonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ButtonTableViewCell"];
		if (cell == nil) {
			UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"ButtonTableViewCell" bundle:nil];
			cell = (ButtonTableViewCell *)viewController.view;
		}
		// Configure the cell
		cell.text = @"Dismiss";
		[cell addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

		return cell;
	}
	if([indexPath row] == 0) {
		
		UserDetailsHeaderCell *cell = nil;
		cell = (UserDetailsHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"UserDetailsHeaderCell"];
		if (cell == nil) {
			UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"UserDetailsHeaderCell" bundle:nil];
			cell = (UserDetailsHeaderCell *)viewController.view;
			[viewController release];
			[cell label].font = [UIFont boldSystemFontOfSize:25.0];
		}
		// Configure the cell
		[cell label].text = [friend displayName];
		UIImage *image = [[ProfileImageCache mainCache] retrieveImageForUser:[friend uid]];
		[[cell imageView] setImage:image];
		return cell;
	}
	
	UserDetailsDetailCell *cell = nil;
	cell = (UserDetailsDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"UserDetailsDetailCell"];
	if (cell == nil) {
		UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"UserDetailsDetailCell" bundle:nil];
		cell = (UserDetailsDetailCell *)viewController.view;
		[viewController release];
		[cell label].font = [UIFont boldSystemFontOfSize:17.0];
	}
	// Configure the cell
	switch ([indexPath row]) {
		case 1:
			[cell label].text = @"Full name";
			[cell value].text = [friend fullName] ? [friend fullName] : @"Unknown";
			break;
		case 2:
			[cell label].text = @"Gender";
			[cell value].text = (([friend gender] == PlurkGenderMale) ? @"Male" : @"Female");
			break;
		case 3: {
			[cell label].text = @"Karma";
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			formatter.minimumFractionDigits = 2;
			formatter.maximumFractionDigits = 2;
			[cell value].text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithFloat:[friend karma]]], nil];
			[formatter release];
			break;
		}
		case 4:
			[cell label].text = @"Relationship";
			[cell value].text = [friend relationship];
			break;
		case 5:
			[cell label].text = @"Location";
			[cell value].text = [friend location] ? [friend location] : @"Unknown";
			break;
		default:
			[cell label].text = @"Error";
			[cell value].text = @"Error";
			break;
	}
	return cell;
}

- (void)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 0 && [indexPath row] == 0) {
		return 60.0f;
	} else {
		return [tableView rowHeight];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 0) {
		return nil;
	}
	return indexPath;
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/



- (void)viewWillAppear:(BOOL)animated {
	[[self tableView] reloadData];
    [super viewWillAppear:animated];
}

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
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
	[friend release];
    [super dealloc];
}


@end

