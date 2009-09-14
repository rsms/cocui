#import "jsbridge.h"

@implementation EVSize

CUJS_EXPOSE_THIS_CLASS;
CUJS_TRANSPOND_NAMES_PLAIN;

@synthesize width, height;

-(id)initWithNSSize:(NSSize)st {
	width = [NSNumber numberWithFloat:st.width];
	height = [NSNumber numberWithFloat:st.height];
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"{width:%@, height:%@}", width, height];
}

@end
