#import "jsbridge.h"

id cu_js_forward_invocation(id target, NSString *name, NSArray *args, BOOL strict) {
	//NSLog(@"invokeUndefinedMethodFromWebScript:%@ withArguments:%@", name, args);
	NSString *selname = name; // todo transpose js -> objc
	selname = [selname stringByReplacingOccurrencesOfString:@"_" withString:@":"];
	selname = [selname stringByReplacingOccurrencesOfString:@"$" withString:@"_"];
	// todo handle the case of $$ in names (VERY rare, but spec says it can happen)
	//NSLog(@"selector => %@", selname);
	SEL sel = NSSelectorFromString(selname);
	BOOL responds = [target respondsToSelector:sel];
	if (!responds && !strict && [selname rangeOfString:@":"].length == 0) {
		// :sender is very common, lets try it.
		selname = [selname stringByAppendingString:@":"];
		sel = NSSelectorFromString(selname);
		responds = [target respondsToSelector:sel];
	}
	if (responds) {
		NSMethodSignature *msig = [[target class] instanceMethodSignatureForSelector:sel];
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:msig];
		NSUInteger i, count = [args count];
		// Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively, thus "+2"
		for (i = 0; i < count; i++) {
			id arg = [args objectAtIndex:i];
			[inv setArgument:(void *)&arg atIndex:i+2];
		}
		[inv setSelector:sel];
		[inv retainArguments];
		[inv invokeWithTarget:target];
		id robj = nil;
		if ([msig methodReturnLength])
			[inv getReturnValue:&robj];
		return robj;
	}
	//NSLog(@"target does not respond to selector %@", NSStringFromSelector(sel));
	CUJS_THROW(@"Call to undefined function %@ with arguments %@ (on %@)", name, args, target);
	return nil;
}
