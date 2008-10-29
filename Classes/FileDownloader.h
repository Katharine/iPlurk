//
//  FileDownloader.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FileDownloader : NSObject {
	NSString *targetFile;
	NSMutableData *data;
	id delegate;
}

- (FileDownloader *)initFromURL:(NSURL *)url toFile:(NSString *)target notify:(id)delegate;

@end
