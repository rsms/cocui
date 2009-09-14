#import "WebScriptObject+EVJS.h"
#import "NSString+CUAdditions.h"

@implementation WebScriptObject (EVJS)


- (id)invokeWithArguments:(NSArray *)args inContext:(JSContextRef)jctx {
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
	
	return [isa cocoaRepresentationOfJSValue:retval inContext:jctx];
}


- (id)cocoaRepresentationInContext:(JSContextRef)ctx {
	return [isa cocoaRepresentationOfJSValue:[self JSObject] inContext:ctx];
}

- (NSString *)JSONRepresentationInContext:(JSContextRef)ctx {
	return [isa JSONRepresentationOfJSValue:[self JSObject] inContext:ctx];
}


+ (NSString *)JSONRepresentationOfJSValue:(JSValueRef)o inContext:(JSContextRef)ctx {
	JSType t = JSValueGetType(ctx, (JSValueRef)o);
	
	switch (t) {
			
		case kJSTypeObject: {
			id v = nil;
			//JSObjectRef obj = JSValueToObject(ctx, o, NULL);
			JSObjectRef obj = (JSObjectRef)o;
			JSPropertyNameArrayRef keys = JSObjectCopyPropertyNames(ctx, obj);
			size_t i, count = JSPropertyNameArrayGetCount(keys);
			if (!count)
				return @"{}";
			JSValueRef vval;
			NSString *fmt = @"[%@]";
			
			// note: the array detection will fail if there is an actual undefined value
			//       in the collection. In those cases a dictionary will be created.
			
			// first, try it as an array
			vval = JSObjectGetPropertyAtIndex(ctx, obj, (unsigned int)i, NULL);
			if (vval && !JSValueIsUndefined(ctx, vval)) {
				// array
				v = [NSMutableArray arrayWithCapacity:count];
				[v addObject:[self JSONRepresentationOfJSValue:vval inContext:ctx]];
				
				for (i=1; i<count; i++) {
					vval = JSObjectGetPropertyAtIndex(ctx, obj, (unsigned int)i, NULL);
					if (!vval || JSValueIsUndefined(ctx, vval)) {
						// turns out it's not a pure array
						v = nil;
						break;
					}
					[v addObject:[self JSONRepresentationOfJSValue:vval inContext:ctx]];
				}
			}
			
			if (!v) {
				v = [NSMutableArray arrayWithCapacity:count];
				// dict
				for (i=0; i<count; i++) {
					JSStringRef k = JSPropertyNameArrayGetNameAtIndex(keys, i);
					JSValueRef vval = JSObjectGetProperty(ctx, obj, k, NULL);
					// JSValueRef vval = JSObjectGetPropertyAtIndex(ctx, obj, (unsigned int)i, NULL);
					if (!vval) {
						// todo error handling
						return nil;
					}
					[v addObject:[NSString stringWithFormat:@"%@:%@", [CU_JSStringToNSString(k) JSONRepresentation], [self JSONRepresentationOfJSValue:vval inContext:ctx]]];
				}
				fmt = @"{%@}";
			}
			
			v = [NSString stringWithFormat:fmt, [v componentsJoinedByString:@","]];
			return v;
		}
			
		case kJSTypeUndefined:
			return @"undefined";
			
		case kJSTypeNull:
			return @"null";
			
		case kJSTypeBoolean:
			return JSValueToBoolean(ctx, (JSValueRef)o) ? @"true" : @"false";
			
		case kJSTypeNumber:
			return [NSString stringWithFormat:@"%f", JSValueToNumber(ctx, (JSValueRef)o, NULL)];
			
		case kJSTypeString: {
			JSStringRef jstr;
			if ((jstr = JSValueToStringCopy(ctx, (JSValueRef)o, NULL)))
				return [CU_JSStringToNSString(jstr) JSONRepresentation];
			return @"";
		}
	}
	
	return nil;
}


+ (id)cocoaRepresentationOfJSValue:(JSValueRef)o inContext:(JSContextRef)ctx {
	JSType t = JSValueGetType(ctx, (JSValueRef)o);
	id v = nil;
	
	switch (t) {
		
		case kJSTypeObject: {
			//JSObjectRef obj = JSValueToObject(ctx, o, NULL);
			JSObjectRef obj = (JSObjectRef)o;
			JSPropertyNameArrayRef keys = JSObjectCopyPropertyNames(ctx, obj);
			size_t i, count = JSPropertyNameArrayGetCount(keys);
			if (!count)
				return [NSMutableDictionary dictionaryWithCapacity:0];
			JSValueRef vval;
			
			// note: the array detection will fail if there is an actual undefined value
			//       in the collection. In those cases a dictionary will be created.
			
			// first, try it as an array
			vval = JSObjectGetPropertyAtIndex(ctx, obj, (unsigned int)i, NULL);
			if (vval && !JSValueIsUndefined(ctx, vval)) {
				// array
				v = [NSMutableArray arrayWithCapacity:count];
				[v addObject:[self cocoaRepresentationOfJSValue:vval inContext:ctx]];
				
				for (i=1; i<count; i++) {
					vval = JSObjectGetPropertyAtIndex(ctx, obj, (unsigned int)i, NULL);
					if (!vval || JSValueIsUndefined(ctx, vval)) {
						// turns out it's not a pure array
						v = nil;
						break;
					}
					[v addObject:[self cocoaRepresentationOfJSValue:vval inContext:ctx]];
				}
			}
			
			if (!v) {
				v = [NSMutableDictionary dictionaryWithCapacity:count];
				// dict
				for (i=0; i<count; i++) {
					JSStringRef k = JSPropertyNameArrayGetNameAtIndex(keys, i);
					JSValueRef vval = JSObjectGetProperty(ctx, obj, k, NULL);
					// JSValueRef vval = JSObjectGetPropertyAtIndex(ctx, obj, (unsigned int)i, NULL);
					if (!vval) {
						// todo error handling
						return nil;
					}
					[v setObject:[self cocoaRepresentationOfJSValue:vval inContext:ctx] forKey:CU_JSStringToNSString(k)];
				}
			}
			return v;
		}
			
		case kJSTypeUndefined:
			return [WebUndefined undefined];
		
		case kJSTypeNull:
			return nil;
		
		case kJSTypeBoolean:
			return [NSNumber numberWithBool:JSValueToBoolean(ctx, (JSValueRef)o)];
			
		case kJSTypeNumber:
			return [NSNumber numberWithDouble:JSValueToNumber(ctx, (JSValueRef)o, NULL)];
		
		case kJSTypeString: {
			JSStringRef jstr;
			jstr = JSValueToStringCopy(ctx, (JSValueRef)o, NULL);
			return jstr ? CU_JSStringToNSString(jstr) : nil;
		}
	}
	
	return v;
}


@end
