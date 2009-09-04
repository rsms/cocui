#import "jsbridge.h"

// Expose some of the standard classes
EVJS_EXPOSE_CLASS(NSMutableDictionary);

@implementation EVJSBridge

@synthesize version, application, window;

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name {
	return NO;
}

- (NSString *)description {
	return @"<EV>";
}

@end
