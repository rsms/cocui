// An ImageView with knowledge of image source URL

@interface CUImageView : NSImageView {
	NSURL *imageURL;
}

@property(assign) NSURL *imageURL;

@end
