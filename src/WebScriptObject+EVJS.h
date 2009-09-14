#import <JavaScriptCore/JavaScriptCore.h>

#define CU_JSStringToNSString(jstr) \
	((NSString *)JSStringCopyCFString(kCFAllocatorDefault, jstr))

@interface WebScriptObject (EVJS)

- (id)invokeWithArguments:(NSArray *)args inContext:(JSContextRef)jctx;

+ (id)cocoaRepresentationOfJSValue:(JSValueRef)val inContext:(JSContextRef)ctx;
+ (NSString *)JSONRepresentationOfJSValue:(JSValueRef)val inContext:(JSContextRef)ctx;

- (id)cocoaRepresentationInContext:(JSContextRef)ctx;
- (NSString *)JSONRepresentationInContext:(JSContextRef)ctx;

@end
