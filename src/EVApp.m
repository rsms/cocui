#import "EVApp.h"
#import "WebScriptObject+EVJS.h"

#import "webkit-private/WebInspector.h"
#import "webkit-private/WebInspectorWindowController.h"

//#define WITH_FSCRIPT 1
#if WITH_FSCRIPT
	#import <FScript/FScript.h>
#endif

#define kEVJavascriptNamespace @"App"


@implementation WebInspectorWindowController (OverrideCloseAction)
// This is a fix for the broken WebInspector which window can not be closed once we have opened it
- (BOOL)windowShouldClose:(id)window {
	[window orderOut:self];
	return NO;
}
@end


@implementation EVApp

- (id)init {
	[super init];
	[self setDelegate:self];
	
	jsapp = [[EVJSApp alloc] init];
	jsapp.version = @"0.0.1";
	jsapp.app = self;
	jsapp.defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	jsapp.defaults = [jsapp.defaultsController defaults];
	
	// development mode
	developmentMode = [jsapp.defaults boolForKey:@"DevelopmentMode"];
	[jsapp.defaults setBool:developmentMode forKey:@"WebKitDeveloperExtras"];
	if (developmentMode) {
		NSLog(@"starting in development mode");
		[jsapp.defaults setBool:NO forKey:@"WebKitInspectorAttached"];
		[jsapp.defaults setBool:YES forKey:@"WebKit Web Inspector Setting - resourceTrackingEnabled"];
	}
	else {
		// write it so people can find it when looking in Info.plist
		[jsapp.defaults setBool:NO forKey:@"DevelopmentMode"];
		[jsapp.defaults removeObjectForKey:@"WebKitDeveloperExtras"];
	}
	
	return self;
}

- (void)awakeFromNib {
	if (developmentMode) {
		NSRange er;
		logTextAttrs = [[logTextView textStorage] attributesAtIndex:0 effectiveRange:&er];
		[[logTextView textStorage] deleteCharactersInRange:NSMakeRange(0, [[logTextView textStorage] length])];
		[logTextView setTextContainerInset:NSMakeSize(2.0, 2.0)];
		[self dlog:@"starting in development mode"];
	}
	else {
		[[NSApp mainMenu] removeItem:[[NSApp mainMenu] itemWithTitle:@"Develop"]];
		//[logPanel release];
		logPanel = nil;
	}
}


- (void)dlog:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	[self dlog:format args:args];
	va_end(args);
}


- (void)dlog:(NSString *)format args:(va_list)args {
	if (developmentMode) {
		format = [[NSString alloc] initWithFormat:format arguments:args];
		[logTextView insertText:[[NSAttributedString alloc] 
								 initWithString:[NSString stringWithFormat:@"%@ %@\n", [NSDate date], format]
								 attributes:logTextAttrs]];
	}
	NSLogv(format, args);
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Set ourselves as delegate for frame loading and UI
	[webView setFrameLoadDelegate:self];
	[webView setUIDelegate:self];
	
	// do not draw solid background by default
	[webView setDrawsBackground:NO];
	
	// F-Script
#if WITH_FSCRIPT
	[[NSApp mainMenu] addItem:[[FScriptMenuItem alloc] init]];
#endif
	
	// update jsapp
	jsapp.window = mainWindow;
	
	// set webview prefs
	WebPreferences *preferences = [WebPreferences standardPreferences];
	[preferences setUserStyleSheetLocation:[[NSURL alloc] 
											initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"css"]
											isDirectory:false]];
	[preferences setUserStyleSheetEnabled:YES];
	[webView setPreferences:preferences];
	
	// load index.html
	NSURL *indexURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] isDirectory:false];
#if 1
	indexURL = [[NSURL alloc] 
				initFileURLWithPath:@"/Users/rasmus/src/cocojs/resources/index.html"
				isDirectory:false];
	
#endif
	NSLog(@"indexURL = %@", indexURL);
	NSURLRequest *req = [NSURLRequest requestWithURL:indexURL];
	[[webView mainFrame] loadRequest:req];
	//NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES];
}


-(WebInspector *)webInspector {
	if (!webInspector)
		webInspector = [[NSClassFromString(@"WebInspector") alloc] initWithWebView:webView];
	if (!webInspectorWindowController)
		webInspectorWindowController = [[NSClassFromString(@"WebInspectorWindowController") alloc] initWithInspectedWebView:webView];
	return webInspector;
}


#pragma mark -
#pragma mark UI actions


-(IBAction)showInspector:(id)sender {
	[self dlog:@"displaying web inspector"];
	[[self webInspector] show:webInspectorWindowController];
}

-(IBAction)showConsole:(id)sender {
	[self dlog:@"displaying web inspector with console"];
	[[self webInspector] showConsole:webInspectorWindowController];
}


#pragma mark -
#pragma mark NSApplication delegate methods

// events

#define _NOTIFICATION_TO_JSEVENT(_name_)\
- (void)_name_:(NSNotification *)notification {\
	DOMDocument *d = [[webView mainFrame] DOMDocument];\
	if (d) {\
		DOMEvent *ev = [d createEvent:@"Event"];\
		[ev initEvent:@"" #_name_ canBubbleArg:NO cancelableArg:YES];\
		[d dispatchEvent:ev];\
	}\
}

_NOTIFICATION_TO_JSEVENT(applicationWillBecomeActive)
_NOTIFICATION_TO_JSEVENT(applicationDidBecomeActive)
_NOTIFICATION_TO_JSEVENT(applicationWillResignActive)
_NOTIFICATION_TO_JSEVENT(applicationDidResignActive)
_NOTIFICATION_TO_JSEVENT(applicationWillTerminate)
_NOTIFICATION_TO_JSEVENT(applicationWillHide)
_NOTIFICATION_TO_JSEVENT(applicationDidHide)
_NOTIFICATION_TO_JSEVENT(applicationWillUnhide)
_NOTIFICATION_TO_JSEVENT(applicationDidUnhide)


- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	NSLog(@"openFiles: %@", filenames);
	
	// call onOpenFiles callback, if present
	if (jsapp.onOpenFiles)
		[jsapp.onOpenFiles invokeWithArguments:filenames inContext:jctx];
}


#pragma mark -
#pragma mark WebFrameLoadDelegate methods

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
	// expose jsns namespace in javascript
	// the script object need to be updated before every page load
	[[webView windowScriptObject] setValue:jsapp forKey:kEVJavascriptNamespace];
	jctx = [[webView mainFrame] globalContext];
	if (developmentMode) {
		NSMutableURLRequest *req = [[frame dataSource] request];
		[self dlog:@"commit %@ %@ in %@", [req HTTPMethod], [req URL], frame];
	}
}


- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
	if (frame == [webView mainFrame]) {
		[mainWindow setTitle:title];
	}
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	NSLog(@"[%@] loaded", frame);
	if (developmentMode) {
		NSMutableURLRequest *req = [[frame dataSource] request];
		[self dlog:@"completed %@ %@ in %@", [req HTTPMethod], [req URL], frame];
	}
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	NSLog(@"[%@] failed to load: %@", frame, error);
	if (developmentMode) {
		NSMutableURLRequest *req = [[frame dataSource] request];
		[self dlog:@"failed %@ %@ in %@: %@", [req HTTPMethod], [req URL], frame, error];
	}
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
	NSLog(@"ALERT [%@] %@", frame, message);
	NSBeginInformationalAlertSheet(@"Notice", nil, nil, nil, [sender window], nil, NULL, NULL, NULL, message);
}


/*- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
	return defaultMenuItems;
}*/


#pragma mark -
#pragma mark WebResourceLoadDelegate methods

// We can use this to disallow certain requests (including XHR)
/*
 [webView setResourceLoadDelegate:self];
 - (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
 NSLog(@"request %@ (%@) (%@)", request, identifier, dataSource);
 return request;
 }*/


#pragma mark -
#pragma mark Unofficial delegate methods


- (void)webView:(WebView *)sender addMessageToConsole:(NSDictionary *)message {
	NSNumber *lineNumber = [message objectForKey:@"lineNumber"];
	id msg = [message objectForKey:@"message"];
	NSURL *sourceURL = [message objectForKey:@"sourceURL"];
	[self dlog:@"[%@:%@] %@", sourceURL, lineNumber, msg];
}


@end
