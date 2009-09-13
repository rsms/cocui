#import "jsbridge.h"

@implementation NSMutableDictionary (EVJSExposure)

EVJS_EXPOSE_THIS_CLASS;
EVJS_TRANSPOND_NAMES_PLAIN;

- (id)invokeUndefinedMethodFromWebScript:(NSString *)name withArguments:(NSArray *)args {
	if ([args count] == 0)
		return [self objectForKey:name];
	return nil;
}

@end