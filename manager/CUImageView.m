#import "CUImageView.h"

@implementation CUImageView

- (void)setImageURL:(NSURL *)url {
	imageURL = url;
	[self setImage:[[NSImage alloc] initByReferencingURL:url]];
}

- (NSURL *)imageURL {
	return imageURL;
}

- (void)setImage:(NSImage *)image {
	NSLog(@"setImage");
	if (imageURL)
		[image setName:[[[imageURL path] lastPathComponent] stringByDeletingPathExtension]];
	[super setImage:image];
}

- (BOOL)performDragOperation:(id )sender {
	NSLog(@"drag");
	BOOL dragSucceeded = [super performDragOperation:sender];
	if (dragSucceeded) {
		imageURL = nil;
		NSString *pb = [[sender draggingPasteboard] stringForType:NSURLPboardType];
		if (pb) {
			NSArray *urls = [NSPropertyListSerialization propertyListFromData:[pb dataUsingEncoding:NSUTF8StringEncoding] mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
			if ([urls count])
				imageURL = [NSURL URLWithString:[urls objectAtIndex:0]];
		}
	}
	return dragSucceeded;
}

@end
