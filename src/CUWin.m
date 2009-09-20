#import "CUWin.h"
#import "jsbridge.h"

@implementation CUWin

CUJS_TRANSPOND_NAMES_PLAIN
CUJS_FORWARD_INVOCATION_TO(win)


+ (BOOL)isKeyExcludedFromWebScript:(const char *)name { return NO; }
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
	if (sel == @selector(initWithWindow:))
		return YES;
	return NO;
}


-(id)initWithWindow:(CUWindow *)w {
	self = [super init];
	win = w;
	fullscreen = -1;
	return self;
}


-(NSString *)valueOf {
	return [self description];
}


-(WebScriptObject *)window {
	return [[win.webView mainFrame] windowObject];
}


-(WebScriptObject *)document {
	return [[[win.webView mainFrame] windowObject] valueForKey:@"document"];
}


- (EVRect *)frame {
	return [[EVRect alloc] initWithNSRect:[win frame]];
}


- (void)setFrame:(id)f {
	id origin = [f valueForKey:@"origin"];
	id size = [f valueForKey:@"size"];
	NSRect r = NSMakeRect([[origin valueForKey:@"x"] floatValue], [[origin valueForKey:@"y"] floatValue],
						  [[size valueForKey:@"width"] floatValue], [[size valueForKey:@"height"] floatValue]);
	[win setFrame:r display:YES animate:YES];
}


/*- (NSArray *)position {
	NSRect r = [self frame];
	return [NSArray arrayWithObjects:[NSNumber numberWithFloat:r.origin.x], [NSNumber numberWithFloat:r.origin.y], nil];
}*/


-(BOOL)fullscreen {
	return fullscreen != -1 ? YES : NO;
}


-(void)setFullscreen:(BOOL)b {
	if (b && fullscreen == -1) {
		fullscreen = CGMainDisplayID();
		if ([win.app enterFullscreen:fullscreen]) {
			CUJS_DISPATCH_EVENT(windowDidEnterFullscreen, [[win.webView mainFrame] DOMDocument]);
			_levelBeforeFullscreen = [win level];
			_frameBeforeFullscreen = [win frame];
			[win setLevel:CGShieldingWindowLevel()];
			[win setFrame:[[NSScreen mainScreen] frame] display:YES];
		}
		else {
			fullscreen = -1;
		}
	}
	else if (fullscreen != -1 && [win.app exitFullscreen:fullscreen]) {
		CUJS_DISPATCH_EVENT(windowDidExitFullscreen, [[win.webView mainFrame] DOMDocument]);
		fullscreen = -1;
		[win setLevel:_levelBeforeFullscreen];
		[win setFrame:_frameBeforeFullscreen display:YES];
	}
}


-(BOOL)shadow {
	return [win hasShadow];
}


-(void)setShadow:(BOOL)b {
	return [win setHasShadow:b];
}


-(NSString *)level {
	return [NSString stringWithUTF8String:[CUWindow windowLevelNameForLevel:[win level]]];
}


-(void)setLevel:(id)s {
	CGWindowLevelKey d = [CUWindow windowLevelKeyFromNameOrNumber:s];
	if (d != -1) {
		NSLog(@"setting window level to %d", d);
		[win setLevel:CGWindowLevelForKey(d)];
	}
	else {
		id obj = s;
		if (![s respondsToSelector:@selector(setException:)])
			obj = [win.webView windowScriptObject];
		[obj setException:[NSString stringWithFormat:@"Invalid window level %@", [s description]]];
	}
}



@end
