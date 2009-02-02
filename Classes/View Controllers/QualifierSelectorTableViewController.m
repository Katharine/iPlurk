//
//  QualifierSelectorTableViewController.m
//  iPlurk
//
//  Created on 19/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "QualifierSelectorTableViewController.h"


@implementation QualifierSelectorTableViewController
@synthesize qualifier, delegate, action, language;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	if(nil == qualifier) {
		qualifier = [Qualifiers defaultQualifier];
	}
	if(nil == translations) {
		translations = [[NSMutableArray alloc] init];
	}
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [translations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Configure the cell
    cell.text = [[translations objectAtIndex:[indexPath row]] objectForKey:@"translation"];
	if([[[translations objectAtIndex:[indexPath row]] objectForKey:@"qualifier"] isEqualToString:qualifier]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	for(NSInteger i = 0; i < [[self tableView] numberOfRowsInSection:0]; ++i) {
		[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
	}
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	qualifier = [[translations objectAtIndex:[indexPath row]] objectForKey:@"qualifier"];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if(delegate && action && [delegate respondsToSelector:action]) {
		[delegate performSelector:action withObject:qualifier];
	}
	[[self navigationController] popViewControllerAnimated:YES];
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
	[translations removeAllObjects];
	for(NSString *qual in [Qualifiers list]) {
		NSString *translation = [[Qualifiers sharedQualifiers] translateQualifier:qual to:language];
		if([translation length] == 0 && [qual length] > 1) continue;
		[translations addObject:[NSDictionary dictionaryWithObjectsAndKeys:qual, @"qualifier", translation, @"translation", nil]];
	}
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
	[qualifier release];
	[translations release];
	[language release];
    [super dealloc];
}


@end

