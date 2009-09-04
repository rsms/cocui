@interface EVRect : NSObject {
	EVPoint *origin;
	EVSize *size;
}

@property(assign) EVPoint *origin;
@property(assign) EVSize *size;

-(id)initWithNSRect:(NSRect)r;

@end
