#import "jsbridge.h"

@implementation NSUserDefaults (EVJSExposure)

CUJS_EXPOSE_THIS_CLASS;
CUJS_TRANSPOND_NAMES_PLAIN;

- (id)invokeUndefinedMethodFromWebScript:(NSString *)name withArguments:(NSArray *)args {
	if ([args count] == 0)
		return [self objectForKey:name];
	else
		[self setObject:[args objectAtIndex:0] forKey:name];
	return nil;
}

@end
