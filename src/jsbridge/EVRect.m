#import "jsbridge.h"

@implementation EVRect

CUJS_EXPOSE_THIS_CLASS;
CUJS_TRANSPOND_NAMES_PLAIN;

@synthesize origin, size;

-(id)initWithNSRect:(NSRect)r {
	origin = [[EVPoint alloc] initWithNSPoint:r.origin];
	size = [[EVSize alloc] initWithNSSize:r.size];
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"{origin:%@, size:%@}", origin, size];
}

@end
