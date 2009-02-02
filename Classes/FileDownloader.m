//
//  FileDownloader.m
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "FileDownloader.h"
#import <CoreGraphics/CoreGraphics.h>
#import "Quartz.h"

@implementation FileDownloader

- (FileDownloader *)initFromURL:(NSURL *)url withIdentifier:(id)aId delegate:(id)aDelegate {
	identifier = [aId retain];
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
	//NSLog(@"Writing %d bytes of data to %@", [data length], targetFile);
	if([delegate respondsToSelector:@selector(fileDownloadWithIdentifier:completedWithData:)]) {
		[delegate performSelector:@selector(fileDownloadWithIdentifier:completedWithData:) withObject:identifier withObject:data];
	}
	[data setLength:0];
	[data release];
}

+ (UIImage *)addRoundedCorners:(UIImage *)img {
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
	return newImage;
}

@end
