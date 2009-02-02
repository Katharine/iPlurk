//
//  FileDownloader.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FileDownloader : NSObject {
	id identifier;
	NSMutableData *data;
	id delegate;
}

- (FileDownloader *)initFromURL:(NSURL *)url withIdentifier:(id)ident delegate:(id)del;
+ (UIImage *)addRoundedCorners:(UIImage *)img;

@end
