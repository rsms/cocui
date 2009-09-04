@interface EVSize : NSObject {
	NSNumber *width;
	NSNumber *height;
}

@property(assign) NSNumber *width;
@property(assign) NSNumber *height;

-(id)initWithNSSize:(NSSize)st;

@end
