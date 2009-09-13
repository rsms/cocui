#import <JavaScriptCore/JavaScriptCore.h>

@interface WebScriptObject (EVJS)

- (JSValueRef)invokeWithArguments:(NSArray *)args inContext:(JSContextRef)jctx;

@end
