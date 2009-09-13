#import "jsbridge.h"

@implementation NSWindow (EVJS)

EVJS_EXPOSE_THIS_CLASS;
EVJS_TRANSPOND_NAMES_PLAIN;

- (EVRect *)_frame {
	return [[EVRect alloc] initWithNSRect:[self frame]];
}

- (void)set_frame:(id)frame {
	// input nodes might be an EVRect/EVPoint/EVSize or a WebScriptObjects'
	id origin = [frame valueForKey:@"origin"];
	id size = [frame valueForKey:@"size"];
	NSRect r = NSMakeRect([[origin valueForKey:@"x"] floatValue], [[origin valueForKey:@"y"] floatValue],
						  [[size valueForKey:@"width"] floatValue], [[size valueForKey:@"height"] floatValue]);
	//NSLog(@"%f, %f, %f, %f", r.origin.x, r.origin.y, r.size.width, r.size.height);
	[self setFrame:r display:YES animate:YES];
}

- (NSArray *)position {
	NSRect r = [self frame];
	return [NSArray arrayWithObjects:[NSNumber numberWithFloat:r.origin.x], [NSNumber numberWithFloat:r.origin.y], nil];
}

- (id)invokeDefaultMethodWithArguments:(NSArray *)args {
	NSLog(@"self invoked");
	return nil;
}

- (id)invokeUndefinedMethodFromWebScript:(NSString *)name withArguments:(NSArray *)args {
	//NSLog(@"undefined invoked: %@(%@)", name, args);
	return nil;
}

@end

