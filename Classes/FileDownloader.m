//
//  FileDownloader.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "FileDownloader.h"


@implementation FileDownloader

- (FileDownloader *)initFromURL:(NSURL *)url toFile:(NSString *)target notify:(id)aDelegate {
	targetFile = [target retain];
	delegate = aDelegate;
	data = [[NSMutableData alloc] init];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection release];
	[request release];
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dataChunk {
	[data appendData:dataChunk];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[data setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Writing %d bytes of data to %@", [data length], targetFile);
	[data writeToFile:targetFile atomically:NO];
	[data setLength:0];
	[data release];
	[delegate performSelector:@selector(fileDownloadDidComplete:) withObject:targetFile];
	//[targetFile release];
}

@end
