#import "jsbridge.h"

@implementation EVPoint

CUJS_EXPOSE_THIS_CLASS;
CUJS_TRANSPOND_NAMES_PLAIN;

@synthesize x, y;

-(id)initWithNSPoint:(NSPoint)st {
	x = [NSNumber numberWithFloat:st.x];
	y = [NSNumber numberWithFloat:st.y];
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"{x:%@, y:%@}", x, y];
}

@end
