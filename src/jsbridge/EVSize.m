#import "jsbridge.h"

@implementation EVSize

EVJS_EXPOSE_THIS_CLASS;
EVJS_TRANSPOND_NAMES_PLAIN;

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
