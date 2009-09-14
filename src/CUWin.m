#import "CUWin.h"
#import "jsbridge.h"

@implementation CUWin

CUJS_TRANSPOND_NAMES_PLAIN
CUJS_FORWARD_INVOCATION_TO(window)


+ (BOOL)isKeyExcludedFromWebScript:(const char *)name { return NO; }
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
	if (sel == @selector(initWithWindow:))
		return YES;
	return NO;
}


-(id)initWithWindow:(CUWindow *)w {
	self = [super init];
	window = w;
	fullscreen = -1;
	return self;
}


-(NSString *)valueOf {
	return [self description];
}


-(BOOL)fullscreen {
	return fullscreen != -1 ? YES : NO;
}


-(void)setFullscreen:(BOOL)b {
	if (b && fullscreen == -1) {
		fullscreen = CGMainDisplayID();
		if ([window.app enterFullscreen:fullscreen]) {
			CUJS_DISPATCH_EVENT(windowDidEnterFullscreen, [[window.webView mainFrame] DOMDocument]);
			_levelBeforeFullscreen = [window level];
			_frameBeforeFullscreen = [window frame];
			[window setLevel:CGShieldingWindowLevel()];
			[window setFrame:[[NSScreen mainScreen] frame] display:YES];
		}
		else {
			fullscreen = -1;
		}
	}
	else if (fullscreen != -1 && [window.app exitFullscreen:fullscreen]) {
		CUJS_DISPATCH_EVENT(windowDidExitFullscreen, [[window.webView mainFrame] DOMDocument]);
		fullscreen = -1;
		[window setLevel:_levelBeforeFullscreen];
		[window setFrame:_frameBeforeFullscreen display:YES];
	}
}


-(BOOL)shadow {
	return [window hasShadow];
}


-(void)setShadow:(BOOL)b {
	return [window setHasShadow:b];
}


-(NSString *)level {
	return [NSString stringWithUTF8String:[CUWindow windowLevelNameForLevel:[window level]]];
}


-(void)setLevel:(id)s {
	CGWindowLevelKey d = [CUWindow windowLevelKeyFromNameOrNumber:s];
	if (d != -1) {
		NSLog(@"setting window level to %d", d);
		[window setLevel:CGWindowLevelForKey(d)];
	}
	else {
		id obj = s;
		if (![s respondsToSelector:@selector(setException:)])
			obj = [window.webView windowScriptObject];
		[obj setException:[NSString stringWithFormat:@"Invalid window level %@", [s description]]];
	}
}



@end
