//
//  PlurkReplyTableViewController.m
//  iPlurk
//
//  Created on 18/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "WritePlurkTableViewController.h"


@implementation WritePlurkTableViewController
@synthesize plurkToReplyTo, plurkToEdit, creatingNewPlurk, entryCell, qualifierCell, languageCell;
@synthesize qualifierTable, languageTable;
@synthesize initialContent, initialQualifier;

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
	
	tryingToQuit = NO;
	allowInteraction = YES;
	[qualifierTable setDelegate:self];
	[qualifierTable setAction:@selector(handleQualifierSelected:)];
	
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(confirmBackButton)];
	[[self navigationItem] setLeftBarButtonItem:cancel];
	[cancel release];
	
	UIBarButtonItem *send = nil;
	if(plurkToReplyTo) {
		[[self navigationItem] setTitle:@"Reply to Plurk"];
		entryCell.qualifierEnabled = YES;
		send = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(submitReply)];
	} else if(plurkToEdit) {
		[[self navigationItem] setTitle:@"Edit Plurk"];
		send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePlurk)];
	} else if(creatingNewPlurk) {
		[[self navigationItem] setTitle:@"Write Plurk"];
		entryCell.qualifierEnabled = YES;
		send = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(submitNewPlurk)];
	}
	[send setEnabled:NO];
	[[self navigationItem] setRightBarButtonItem:send];
	[send release];
	firstView = YES;
	
	[self setQualifierLanguage:[Qualifiers defaultLanguage]];
}

- (void)submitNewPlurk {
	NSString *qual = [[qualifierCell qualifier] text];
	if([entryCell qualifier]) {
		qual = [entryCell qualifier];
	}
	NSString *text = [[entryCell text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	PlurkResponsesViewController *parent = (PlurkResponsesViewController *)[(UINavigationController *)[[self parentViewController] parentViewController] topViewController];
	[[PlurkAPI sharedAPI] makePlurk:text withQualifier:qual allowComments:YES limitedTo:nil language:qualifierLanguage delegate:parent];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)handleQualifierSelected:(NSString *)qualifierSelected {
	if([qualifierSelected length] > 0) {
		qualifier = [qualifierSelected retain];
		NSString *translation = [[Qualifiers sharedQualifiers] translateQualifier:qualifier to:qualifierLanguage];
		if([translation length] > 0) {
			[[qualifierCell qualifier] setText:translation];
		} else {
			[[qualifierCell qualifier] setText:qualifier];
		}
		entryCell.qualifierEnabled = [qualifier isEqual:@":"];
		[qualifierTable setQualifier:qualifier];
		if(![[[NSUserDefaults standardUserDefaults] stringForKey:@"persist_qualifier"] isEqualToString:@"0"]) {
			NSLog(@"Saving qualifier: %@", qualifier);
			[[NSUserDefaults standardUserDefaults] setObject:qualifier forKey:@"last_qualifier"];
		}
	}
}

- (void)submitReply {
	NSString *qual = [[qualifierCell qualifier] text];
	if([entryCell qualifier]) {
		qual = [entryCell qualifier];
	}
	NSString *text = [entryCell text];
	PlurkResponsesViewController *parent = (PlurkResponsesViewController *)[(UINavigationController *)[[self parentViewController] parentViewController] topViewController];
	parent.connection = [[PlurkAPI sharedAPI] respondToPlurk:[plurkToReplyTo plurkID] withQualifier:qual content:text language:qualifierLanguage delegate:parent];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)savePlurk {
	PlurkResponsesViewController *parent = (PlurkResponsesViewController *)[(UINavigationController *)[[self parentViewController] parentViewController] topViewController];
	parent.connection = [[PlurkAPI sharedAPI] editPlurk:[plurkToEdit plurkID] setText:[entryCell text] delegate:parent];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)startEmoticonSelector {
	allowInteraction = NO;
	EmoticonPanelController *panel = [[EmoticonPanelController alloc] initWithNibName:@"EmoticonSelector" bundle:nil];
	[panel setDelegate:self];
	[panel setAction:@selector(insertEmoticon:)];
	[[panel view] setFrame:CGRectMake(0, 420, 320, 254)];
	[[self view] addSubview:[panel view]];
	[panel animateIn];
}

- (void)insertEmoticon:(NSString *)emoticon {
	allowInteraction = YES;
	NSString *oldText = [[entryCell textView] text];
	NSString *newText = [[NSString stringWithFormat:@"%@ %@", oldText, emoticon, nil] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	[[entryCell textView] setText:newText];
	[entryCell textViewDidChange:[entryCell textView]];
}

- (void)startPhotoChooser {
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
														   delegate:self
												  cancelButtonTitle:@"Cancel"
											 destructiveButtonTitle:nil
												  otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil
		];
		[sheet showInView:[self view]];
		[sheet release];
	} else if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		[picker setDelegate:self];
		[self presentModalViewController:picker animated:YES];
		[picker release];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photos inaccessible"
														message:@"For some reason, no photos are accessible. Please try again later, or on another device."
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil
		];
		[alert show];
		[alert release];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	if([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
		if(![[[NSUserDefaults standardUserDefaults] stringForKey:@"photo_save"] isEqualToString:@"0"]) { // Default on, if not set.
			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
			NSLog(@"Saved image to photo library.");
			
		}
	}
	UIImage *finalImage = nil;
	if([image size].width > 640 || [image size].height > 640) {
		//NSLog(@"Shrinking image.");
		CGSize newSize = [image size];
		if(newSize.height > 640) {
			newSize.width *= 640 / newSize.height;
			newSize.height = 640;
		}
		if(newSize.width > 640) {
			newSize.height *= 640 / newSize.width;
			newSize.width = 640;
		}
		
		// This message does actually work, but is undocumented and not in the headers. Should try something else.
		if([image respondsToSelector:@selector(_imageScaledToSize:interpolationQuality:)]) {
			finalImage = [image _imageScaledToSize:newSize interpolationQuality:1];
		} else {
			finalImage = image;
		}
	} else {
		finalImage = image;
	}
	
	// Fade in the upload waiting view.
	UIViewController *waiting = [[UIViewController alloc] initWithNibName:@"FileUploadPending" bundle:nil];
	[[picker view] addSubview:[waiting view]];
	CGFloat alpha = [[waiting view] alpha];
	[[waiting view] setAlpha:0.0];
	[[waiting view] setFrame:CGRectMake(0, 0, 320, 480)];
	[UIView beginAnimations:nil context:nil];
	[[waiting view] setAlpha:alpha];
	[UIView commitAnimations];
	
	// Do the upload.
	[self performSelector:@selector(postImageWithDict:) withObject:finalImage afterDelay:0.1];
}

- (void)postImageWithDict:(UIImage *)finalImage {
	// Decide on JPEG or PNG upload
	BOOL useJPEG = YES;
	if([finalImage size].height == 480 && [finalImage size].width == 320) useJPEG = NO;
	
	NSURL *imageUploadURL = [NSURL URLWithString:@"http://up.plu.cc/upload.php"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:imageUploadURL];
	[request setHTTPShouldHandleCookies:NO];
	[request setValue:@"multipart/form-data, boundary=AaB03x" forHTTPHeaderField:@"Content-type"];
	
	NSMutableData *postData = [[NSMutableData alloc] init];
	NSString *contentType = nil;
	if(useJPEG) {
		contentType = @"application/x-iplurk-jpeg";
	} else {
		contentType = @"application/x-iplurk-image";
	}
	[postData appendData:[[NSString stringWithFormat:@"--AaB03x\r\ncontent-disposition: form-data; name=\"image\"; filename=\"iplurk.png\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n", contentType, nil] 
						  dataUsingEncoding:NSUTF8StringEncoding]];
	if(useJPEG) {
		[postData appendData:UIImageJPEGRepresentation(finalImage, 0.8)];
	} else {
		[postData appendData:UIImagePNGRepresentation(finalImage)];
	}
	[postData appendData:[@"\r\n--AaB03x--" dataUsingEncoding:NSUTF8StringEncoding]];
	[request setValue:[[NSNumber numberWithUnsignedInteger:[postData length]] stringValue] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];
	[request setHTTPMethod:@"POST"];
	NSHTTPURLResponse *response;
	NSError *error;
	//NSLog(@"Making request");
	NSData *rawData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *imageURL = nil;
	if([response statusCode] == 200) {
		imageURL = [[NSString alloc] initWithData:rawData encoding:NSASCIIStringEncoding];
	}
	
	// If the upload succeeded, insert the URL.
	if(imageURL) {
		NSString *oldText = [[entryCell textView] text];
		NSString *newText = [[NSString stringWithFormat:@"%@ %@", oldText, imageURL, nil] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[[entryCell textView] setText:newText];
		[entryCell textViewDidChange:[entryCell textView]];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed"
														message:[error localizedDescription]
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil
		];
		[alert show];
		[alert release];
	}
	[self dismissModalViewControllerAnimated:YES];
	
	//[error release];
	//[data release];
	//[rawData release];
	//[finalImage release];
	[request release];
	[postData release];
}

- (void)confirmBackButton {
	if((creatingNewPlurk || plurkToReplyTo) && [[entryCell text] length] == 0 || [[plurkToEdit contentRaw] isEqual:[entryCell text]]) {
		[[self entryCell] resignFirstResponder];
		[self dismissModalViewControllerAnimated:YES];
		return;
	}
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
													   delegate:self
											  cancelButtonTitle:@"Continue Writing"
										 destructiveButtonTitle:nil
											  otherButtonTitles:@"Cancel Plurking", nil
	];
	tryingToQuit = YES;
	[sheet showInView:[self view]];
	[sheet release];
}

- (void)setQualifierLanguage:(NSString *)language {
	if([language isEqualToString:qualifierLanguage]) return;
	qualifierLanguage = [language retain];
	NSString *translated = [[Qualifiers sharedQualifiers] translateQualifier:qualifier to:qualifierLanguage];
	if([translated length] == 0 && [qualifier length] > 1) {
		translated = [[Qualifiers sharedQualifiers] translateQualifier:@"says" to:qualifierLanguage];
	}
	[[qualifierCell qualifier] setText:translated];
	[languageCell setText:[[Qualifiers languages] objectForKey:qualifierLanguage]];
	[qualifierTable setLanguage:qualifierLanguage];
	[entryCell setLanguage:qualifierLanguage];
	[[NSUserDefaults standardUserDefaults] setObject:qualifierLanguage forKey:@"last_language"];
}

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)index {
	if(tryingToQuit) {
		tryingToQuit = NO;
		if(index != [sheet cancelButtonIndex]) {
			[[self entryCell] resignFirstResponder];
			[self dismissModalViewControllerAnimated:YES];
		}
	} else {
		if(index == [sheet cancelButtonIndex]) return;
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		if(index == 1) {
			[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		} else if(index == 0) {
			[picker setSourceType:UIImagePickerControllerSourceTypeCamera];
		}
		[picker setDelegate:self];
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
		return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			if(creatingNewPlurk) {
				return 3;
			} else {
				return 2;
			}
		case 1:
			return 2;
	}
    return 0;
}

- (void)replyDidChange:(NSString *)text {
	NSInteger length = [text length] - [[entryCell qualifier] length];
	if(length > 0 && length <= 140) {
		[[[self navigationItem] rightBarButtonItem] setEnabled:YES];
	} else {
		[[[self navigationItem] rightBarButtonItem] setEnabled:NO];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = nil;
	if([indexPath section] == 0) {
		switch ([indexPath row]) {
			case 2:
				CellIdentifier = @"PlurkLanguageSelectionTableViewCell";
				break;
			case 1:
				CellIdentifier = @"PlurkEntryTableViewCell";
				break;
			case 0:
				CellIdentifier = @"PlurkQualifierTableViewCell";
				break;
		}
	} else if([indexPath section] == 1) {
		CellIdentifier = @"ButtonTableViewCell";
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		@try {
			UIViewController *viewController = [[UIViewController alloc] initWithNibName:CellIdentifier bundle:nil];
			cell = (UITableViewCell *)viewController.view;
			[viewController release];
		} @catch (NSException *exception) {
			cell = [[UITableViewCell alloc] init];
		}
	}
    // Configure the cell
	if([indexPath section] == 0) {
		switch ([indexPath row]) {
			case 2:
				self.languageCell = (PlurkLanguageSelectionTableViewCell *)cell;
				[languageCell initUI];
				[languageCell setText:[[Qualifiers languages] objectForKey:[Qualifiers defaultLanguage]]];
				break;
			case 1:
				self.entryCell = (PlurkEntryTableViewCell *)cell;
				[entryCell initUI];
				[entryCell setChangeAction:@selector(replyDidChange:) target:self];
				break;
			case 0:
				self.qualifierCell = (PlurkQualifierTableViewCell *)cell;
				[qualifierCell initUI];
				[[qualifierCell name] setText:[[[PlurkAPI sharedAPI] currentUser] displayName]];
				[[qualifierCell qualifier] setText:@":"];
				break;
		}
	} else if([indexPath section] == 1) {
		ButtonTableViewCell *button = (ButtonTableViewCell *)cell;
		if([indexPath row] == 0) {
			[button setText:@"Insert emoticon"];
			[button addTarget:self action:@selector(startEmoticonSelector) forControlEvents:UIControlEventTouchUpInside];
		} else if([indexPath row] == 1) {
			[button setText:@"Upload photo"];
			[button addTarget:self action:@selector(startPhotoChooser) forControlEvents:UIControlEventTouchUpInside];
		}
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] == 0) {
		switch ([indexPath row]) {
			case 0:
				return 40.0;
			case 1:
				return 110.0;
		}
	}
	return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!allowInteraction) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		return;
	}
	if(plurkToEdit) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	if([indexPath row] == 0 && [indexPath section] == 0) {
		[[self navigationController] pushViewController:qualifierTable animated:YES];
	} else if([indexPath row] == 2 && [indexPath section] == 0) {
		[[self navigationController] pushViewController:languageTable animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)view heightForHeaderInSection:(NSInteger)section {
	return 0.0;
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



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if(firstView) {
		firstView = NO;
		if(plurkToEdit) {
			//NSLog(@"Doing stuff.");
			entryCell.qualifierEnabled = NO;
			[self setQualifierLanguage:[plurkToEdit lang]];
			[[qualifierCell qualifier] setText:[[Qualifiers sharedQualifiers] translateQualifier:[plurkToEdit qualifier] to:qualifierLanguage]];
			[qualifierCell setAccessoryType:UITableViewCellAccessoryNone];
			[entryCell setText:[plurkToEdit contentRaw]];	
		} else {
			if(initialContent) {
				[entryCell setText:initialContent];
			}
			if(!initialQualifier) {
				if(![[[NSUserDefaults standardUserDefaults] stringForKey:@"persist_qualifier"] isEqualToString:@"0"]) {
					initialQualifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_qualifier"];
					NSLog(@"Loaded qualifier: %@", initialQualifier);
				}
			}
			if(initialQualifier) {
				[self handleQualifierSelected:initialQualifier];
				[entryCell setQualifierEnabled:NO];
			}
			if(creatingNewPlurk) {
				qualifierLanguage = [Qualifiers defaultLanguage];
				[languageTable setSelectedLang:qualifierLanguage];
				[languageTable setDelegate:self];
				[languageTable setAction:@selector(setQualifierLanguage:)];
			}
			if(plurkToReplyTo) {
				[self setQualifierLanguage:[plurkToReplyTo lang]];
			}
		}
	}
}


- (void)viewWillDisappear:(BOOL)animated {
	[[entryCell textView] resignFirstResponder];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/

- (void)didReceiveMemoryWarning {
    // Do nothing. :o
}


- (void)dealloc {
	[entryCell release];
	[plurkToReplyTo release];
	[plurkToEdit release];
	[qualifierCell release];
	[qualifierTable release];
	[initialContent release];
	[initialQualifier release];
    [super dealloc];
}


@end

