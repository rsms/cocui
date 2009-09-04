
@interface EVPoint : NSObject {
	NSNumber *x;
	NSNumber *y;
}

@property(assign) NSNumber *x;
@property(assign) NSNumber *y;

-(id)initWithNSPoint:(NSPoint)st;

@end
