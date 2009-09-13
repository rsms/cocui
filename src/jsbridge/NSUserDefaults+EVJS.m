#import "jsbridge.h"

@implementation NSUserDefaults (EVJSExposure)

EVJS_EXPOSE_THIS_CLASS;
EVJS_TRANSPOND_NAMES_PLAIN;

- (id)invokeUndefinedMethodFromWebScript:(NSString *)name withArguments:(NSArray *)args {
	if ([args count] == 0)
		return [self objectForKey:name];
	else
		[self setObject:[args objectAtIndex:0] forKey:name];
	return nil;
}

@end
