#import "WebScriptObject+EVJS.h"

@implementation WebScriptObject (EVJS)

- (JSValueRef)invokeWithArguments:(NSArray *)args inContext:(JSContextRef)jctx {
	JSObjectRef jobj = [self JSObject];
	JSValueRef *arguments, exception, retval;
	size_t i, count;
	
	if (!jobj || !JSObjectIsFunction(jctx, jobj))
		return NULL;
	
	count = [args count];
	arguments = calloc(count, sizeof(JSValueRef));
	
	for (i = 0; i < count; i++) {
		id arg = [args objectAtIndex:i];
		if ([arg isMemberOfClass:[NSNumber class]]) {
			arguments[i] = JSValueMakeNumber(jctx, [arg doubleValue]);
		}
		else {
			if (![arg isMemberOfClass:[NSString class]])
				arg = [arg description];
			arguments[i] = JSValueMakeString(jctx, JSStringCreateWithCFString((CFStringRef)arg));
		}
	}
	
	exception = NULL;
	retval = JSObjectCallAsFunction(jctx, jobj, NULL, count, arguments, &exception);
	
	free(arguments);
	
	if (exception) {
		NSLog(@"failed to invoke script callback onOpenFiles: %@",
			  JSStringCopyCFString(kCFAllocatorDefault, JSValueToStringCopy(jctx, exception, &exception)));
		return NULL;
	}
	
	return retval;
}

@end
