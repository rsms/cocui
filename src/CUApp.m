#import "jsbridge.h"
#import "WebScriptObject+EVJS.h"
#import "NSDictionary+CUAdditions.h"

#import "EVApp.h"
#import "CUApp.h"
#import "CUWindow.h"

@implementation CUApp

@synthesize version, defaults, defaultsController, webView;

// callbacks
@synthesize onOpenFiles;

// some:thing -> some_thing()
EVJS_TRANSPOND_NAMES_PLAIN

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
	rect: {
		origin: {x: float, y: float}
		size: {width: float, height: float}
	}
	 style: {
		titled: bool (true)
		closable: bool (true)
		miniaturizable: bool (true)
		resizable: bool (true)
		borderless: bool (false)
		textured: bool (false)
	}
	defer: bool (false)
 }
 */
-(id)loadWindow:(WebScriptObject *)jsargs {
	NSURL *url;
	NSString *uri;
	NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
	NSRect contentRect = NSMakeRect(-1.0, -1.0, 300.0, 400.0);
	NSUInteger styleMask = 0;
	//NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
	BOOL defer = NO;
	JSContextRef ctx = [[webView mainFrame] globalContext];
	
	id args = [jsargs cocoaRepresentationInContext:ctx];
	
	if (![[args class] isSubclassOfClass:[NSDictionary class]]) {
		// simple string input (or something else that's not a dict)
		uri = args;
	}
	else {
		// keyword arguments
		NSNumber *n;
		
		if (!(uri = [args objectForKey:@"uri"])) {
			[jsargs setException:@"missing \"uri\" argument"];
			return nil;
		}
		
		// update rect
		NSDictionary *rect = [args objectForKey:@"rect"];
		if (rect && [rect respondsToSelector:@selector(objectForKey:)])
			contentRect = [rect updateRect:contentRect];
		
		// todo: style
		styleMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
		
		if ((n = [args objectForKey:@"defer"]))
			defer = [n boolValue];
	}
	
	// adjust rect origin if needed (center on screen)
	if (contentRect.origin.x < 0.0 || contentRect.origin.y < 0.0) {
		contentRect.origin.x = (visibleFrame.size.width / 2) - (contentRect.size.width / 2);
		contentRect.origin.y = (visibleFrame.size.height / 2) - (contentRect.size.height / 2);
		// todo place a bit higher up (y) a la PHI / golden ratio
	}
	
	// set url
	url = [NSURL alloc];
	uri = [uri description];
	if ([uri rangeOfString:@"://"].length)
		url = [url initWithString:uri];
	else
		url = [url initFileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:uri]];
	
	// create window
	CUWindow *win = [[CUWindow alloc] initWithContentRect:contentRect styleMask:styleMask defer:defer preferences:_webPrefs app:self];
	[win loadURL:url];
	
	// xxx
	//[win makeKeyAndOrderFront:self];
	
	return win;
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
