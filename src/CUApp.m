#import "jsbridge.h"
#import "WebScriptObject+EVJS.h"
#import "NSDictionary+CUAdditions.h"

#import <ApplicationServices/ApplicationServices.h>

#import "EVApp.h"
#import "CUApp.h"
#import "CUWindow.h"

@implementation CUApp

@synthesize version, defaults, defaultsController, webView;

// callbacks
@synthesize onOpenFiles;

// some:thing -> some_thing()
CUJS_TRANSPOND_NAMES_PLAIN

// allow access to all properties
+ (BOOL)isKeyExcludedFromWebScript:(const char *)name { return NO; }

// disallow some selectors
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel {
	if ( sel == @selector(initWithWebPreferences:)
		/*|| sel == @selector(initWithWebPreferences:)*/)
		return YES;
	return NO;
}


-(id)initWithWebPreferences:(WebPreferences *)preferences {
	self = [super init];
	_webPrefs = preferences;
	fullscreen = -1;
	webView = [[WebView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 10.0, 10.0) frameName:@"main" groupName:@"app"];
	[webView setFrameLoadDelegate:self];
	[webView setUIDelegate:self];
	[[webView windowScriptObject] setValue:self forKey:kCUAppWebScriptNamespace];
	return self;
}


-(id)evaluateWebScript:(NSString *)js errorDesc:(NSString **)errdesc {
	JSContextRef ctx = [[webView mainFrame] globalContext];
	JSStringRef script = JSStringCreateWithCFString((CFStringRef)js);
	JSStringRef sourceURL = JSStringCreateWithUTF8CString("<string>");
	JSValueRef exc = NULL;
	JSValueRef val = JSEvaluateScript(ctx, script, [[webView windowScriptObject] JSObject], sourceURL, 1, &exc);
	JSStringRelease(sourceURL);
	if (!val) {
		*errdesc = (NSString *)JSStringCopyCFString(kCFAllocatorDefault, JSValueToStringCopy(ctx, exc, NULL));
		return nil;
	}
	return [WebScriptObject cocoaRepresentationOfJSValue:val inContext:ctx];
	//return [[webView windowScriptObject] evaluateWebScript:js];
}


-(void)terminate {
	[g_app terminate:self];
}


-(NSString *)encodeJSON:(WebScriptObject *)obj {
	return [obj JSONRepresentationInContext:[[webView mainFrame] globalContext]];
}


-(NSString *)decodeJSON:(WebScriptObject *)obj {
	return [[webView windowScriptObject] evaluateWebScript:[NSString stringWithFormat:@"(%@)", obj]];
}


/*
 Arguments:
 {
	uri: string     // e.g. "index.html" or "http://some.thing/"
	name: string    // causes the window frame to be saved in defaults as "nameWindow"
	rect: {
		origin: {x: float, y: float}
		size: {width: float, height: float}
	}
	style: {
		titled: bool (true)
		closable: bool (true)
		miniaturizable: bool (true)
		resizable: bool (true)
		textured: bool (false)
		borderless: bool (false)   // if set, the only valid styles are textured and shadow
		shadow: bool (true)
	}
	fullscreen: bool (false)     // if set, no default style is set (style can still be explicitly set)
	defer: bool (false)
	level: string|int ("normal")
 }
 
 Considered future options:
 
	fullscreen: bool (false)
 
 Window level names: (starting from lowest to highest in the z dimension)
 
	Minimum, Desktop, BackstopMenu, Normal, Floating, TornOffMenu, Dock, MainMenu,
	Status, ModalPanel, PopUpMenu, Dragging, ScreenSaver, Maximum, Overlay, Help,
	Utility, DesktopIcon, Cursor
 */
-(CUWin *)createWindow:(WebScriptObject *)jsargs {
	NSURL *url = nil;
	NSString *uri = nil, *name = nil;
	NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
	NSRect contentRect = NSMakeRect(-1.0, -1.0, 300.0, 400.0);
	NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
	BOOL defer = NO, shadow = YES, _fullscreen = NO;
	JSContextRef ctx = [[webView mainFrame] globalContext];
	CGWindowLevel windowLevel = kCGNormalWindowLevel;
	id args = nil;
	
	if ([jsargs respondsToSelector:@selector(cocoaRepresentationInContext:)])
		args = [jsargs cocoaRepresentationInContext:ctx];
	
	if (!args || ![[args class] isSubclassOfClass:[NSDictionary class]]) {
		// simple string input (or something else that's not a dict)
		uri = (NSString *)jsargs;
	}
	else {
		// keyword arguments
		NSNumber *n;
		NSString *s;
		NSDictionary *d;
		
		//#define BOPT(key, assignto) do { if((n = [args objectForKey:key])) defer = [n boolValue]; } while(0)
		
		uri = [args objectForKey:@"uri"];
		name = [args objectForKey:@"name"];
		
		/*if (!uri) {
			[jsargs setException:@"missing \"uri\" argument"];
			return nil;
		}*/
		
		// update rect
		d = [args objectForKey:@"rect"];
		if (d && [d respondsToSelector:@selector(objectForKey:)])
			contentRect = [d updateRect:contentRect];
		
		// fullscreen
		_fullscreen = ((n = [args objectForKey:@"fullscreen"]) && [n boolValue]);
		if (_fullscreen)
			shadow = NO; // shadow defaults to NO
		
		// style
		/*
		 titled: bool (true)
		 closable: bool (true)
		 miniaturizable: bool (true)
		 resizable: bool (true)
		 textured: bool (false)
		 */
		d = [args objectForKey:@"style"];
		if (d && [d respondsToSelector:@selector(objectForKey:)]) {
			#define OPT_DEFAULT_TRUE(dict, key, flag) \
				( (!(n = [dict objectForKey:key]) || [n boolValue]) ? flag : 0 )
			#define OPT_DEFAULT_FALSE(dict, key, flag) \
				( ((n = [dict objectForKey:key]) && [n boolValue]) ? flag : 0 )
			
			/*
			 Discussion:
			 
			 borderless is special -- if defined, others (except from textured) should 
			 not be set. Also, NSBorderlessWindowMask is 0 (null) which makes things a 
			 bit more complicated and might case problems in the future if the value of
			 NSBorderlessWindowMask is changed.
			*/
			
			styleMask = 0;
			
			if (!(n = [d objectForKey:@"borderless"]) || ![n boolValue]) {
				// only eval these if not borderless
				styleMask |= OPT_DEFAULT_TRUE(d, @"titled", NSTitledWindowMask);
				styleMask |= OPT_DEFAULT_TRUE(d, @"closable", NSClosableWindowMask);
				styleMask |= OPT_DEFAULT_TRUE(d, @"miniaturizable", NSMiniaturizableWindowMask);
				styleMask |= OPT_DEFAULT_TRUE(d, @"resizable", NSResizableWindowMask);
			}
			styleMask |= OPT_DEFAULT_FALSE(d, @"textured", NSTexturedBackgroundWindowMask);
			
			if ((n = [d objectForKey:@"shadow"]))
				shadow = [n boolValue];
			
			#undef OPT_DEFAULT_TRUE
			#undef OPT_DEFAULT_FALSE
		}
		else if (_fullscreen) {
			// no style feats by default when requesting fullscreen
			styleMask = 0;
		}
		
		// defer
		if ((n = [args objectForKey:@"defer"]))
			defer = [n boolValue];
		
		// level
		if ((s = [args objectForKey:@"level"])) {
			CGWindowLevelKey d = [CUWindow windowLevelKeyFromNameOrNumber:s];
			if (windowLevel != -1)
				windowLevel = CGWindowLevelForKey(d);
		}
	}
	
	// adjust rect origin if needed (center on screen)
	if (contentRect.origin.x < 0.0 || contentRect.origin.y < 0.0) {
		contentRect.origin.x = (visibleFrame.size.width / 2) - (contentRect.size.width / 2);
		contentRect.origin.y = (visibleFrame.size.height / 2) - (contentRect.size.height / 2);
		// todo place a bit higher up (y) a la PHI / golden ratio
	}
	
	// set url
	if (uri) {
		url = [NSURL alloc];
		uri = [uri description];
		if ([uri rangeOfString:@"://"].length)
			url = [url initWithString:uri];
		else
			url = [url initFileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:uri]];
	}
		
	// create window
	CUWindow *win = [[CUWindow alloc] initWithContentRect:contentRect styleMask:styleMask defer:defer preferences:_webPrefs app:self];
	
	// set autosave name & possibly apply saved state
	if (name)
		[win setFrameAutosaveName:name];
	
	// set level
	if (windowLevel != kCGNormalWindowLevel)
		[win setLevel:windowLevel];
	
	// set shadow
	if (!shadow)
		[win setHasShadow:NO];
	
	// load url
	if (url)
		[win loadURL:url];
	
	// fullscreen
	if (_fullscreen)
		[win.win setFullscreen:YES];
	
	return win.win;
}


-(BOOL)fullscreen {
	return fullscreen != -1 ? YES : NO;
}


-(void)setFullscreen:(BOOL)b {
	if (b)
		[self enterFullscreen:CGMainDisplayID()];
	else
		[self exitFullscreen];
}


-(BOOL)enterFullscreen:(CGDirectDisplayID)screenID {
	if (fullscreen == -1) {
		if (CGDisplayCapture(screenID) == kCGErrorSuccess) {
			fullscreen = screenID;
			return YES;
		}
		NSLog(@"Failed to capture screen (enter fullscreen)");
		CUJS_THROW(@"Failed to capture screen (enter fullscreen)");
	} else {
		NSLog(@"Avoided entering fullscreen (already in fullscreen mode)");
	}
	return NO;
}

-(CGDirectDisplayID)exitFullscreen {
	CGDirectDisplayID sid = fullscreen;
	if (fullscreen != -1 && [self exitFullscreen:fullscreen]) {
		fullscreen = -1;
		return sid;
	}
	return -1;
}

-(BOOL)exitFullscreen:(CGDirectDisplayID)screenID {
	if (CGDisplayRelease(screenID) == kCGErrorSuccess) {
		if (screenID == fullscreen)
			fullscreen = -1;
		return YES;
	}
	NSLog(@"Failed to release screen %d (exit fullscreen) -- terminating application", fullscreen);
	CUJS_THROW(@"Failed to release screen %d (exit fullscreen) -- terminating application", fullscreen);
	[NSApp terminate:self];
	return NO;
}



#pragma mark -
#pragma mark WebUIDelegate methods

/*- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
 {
 // disable contextual menu for the webView
 return nil;
 }*/

/*
 This method is invoked when the dragged content is dropped and the sender is about to perform the source action. Invoked after the last invocation of the webView:dragSourceActionMaskForPoint: method. Gives the delegate an opportunity to modify the contents of the object on pasteboard before completing the source action.
 */
- (void)webView:(WebView *)sender willPerformDragSourceAction:(WebDragSourceAction)action fromPoint:(NSPoint)point withPasteboard:(NSPasteboard *)pasteboard {
	NSLog(@"dropping %@", pasteboard);
}


- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	//NSLog(@"ALERT [%@] %@", frame, message);
	//NSBeginInformationalAlertSheet(@"Notice", nil, nil, nil, [sender window], nil, NULL, NULL, NULL, message);
	[NSAlert alertWithMessageText:@"Alert" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:message];
}


/*- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
 return defaultMenuItems;
 }*/


// Unofficial:

- (void)webView:(WebView *)sender addMessageToConsole:(NSDictionary *)m {
	[g_app dlog:@"[%@:%@] %@", [m objectForKey:@"sourceURL"], [m objectForKey:@"lineNumber"], [m objectForKey:@"message"]];
}


@end
