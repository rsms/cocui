#import "EVApp.h"
#import "CUWindow.h"
#import "jsbridge.h"

#import "webkit-private/WebInspector.h"
#import "webkit-private/WebInspectorWindowController.h"

@implementation CUWindow

EVJS_EXPOSE_THIS_CLASS
EVJS_TRANSPOND_NAMES_PLAIN

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask defer:(BOOL)defer preferences:(WebPreferences *)webPrefs app:(CUApp *)_app
{
	app = _app;
	self = [self initWithContentRect:contentRect styleMask:styleMask backing:NSBackingStoreBuffered defer:defer];
	webView = [[WebView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 10.0, 10.0) frameName:@"main" groupName:@"app"];
	[webView setFrameLoadDelegate:self];
	[webView setUIDelegate:self];
	[webView setPreferences:webPrefs];
	[webView setDrawsBackground:NO];
	webInspector = nil;
	webInspectorWindowController = nil;
	[self setContentView:webView];
	return self;
}

-(void)loadURL:(NSURL *)url {
	NSLog(@"loading %@ with %@", self, url);
	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}

-(WebInspector *)webInspector {
	if (!webInspector)
		webInspector = [[NSClassFromString(@"WebInspector") alloc] initWithWebView:webView];
	if (!webInspectorWindowController)
		webInspectorWindowController = [[NSClassFromString(@"WebInspectorWindowController") alloc] initWithInspectedWebView:webView];
	return webInspector;
}


#pragma mark -
#pragma mark WebFrameLoadDelegate methods

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
	// expose jsns namespace in javascript
	// the script object need to be updated before every page load
	WebScriptObject *root = [webView windowScriptObject];
	[root setValue:app forKey:kCUAppWebScriptNamespace];
	[root setValue:self forKey:kCUWindowWebScriptNamespace];
	
	if (g_app.developmentMode) {
		NSMutableURLRequest *req = [[frame dataSource] request];
		[g_app dlog:@"commit %@ %@ in %@", [req HTTPMethod], [req URL], frame];
	}
}


- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
	if (frame == [webView mainFrame])
		[self setTitle:title];
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	NSLog(@"[%@] loaded", frame);
	if (g_app.developmentMode) {
		NSMutableURLRequest *req = [[frame dataSource] request];
		[g_app dlog:@"completed %@ %@ in %@", [req HTTPMethod], [req URL], frame];
	}
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	NSLog(@"[%@] failed to load: %@", frame, error);
	if (g_app.developmentMode) {
		NSMutableURLRequest *req = [[frame dataSource] request];
		[g_app dlog:@"failed %@ %@ in %@: %@", [req HTTPMethod], [req URL], frame, error];
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


// Unofficial:

- (void)webView:(WebView *)sender addMessageToConsole:(NSDictionary *)m {
	[g_app dlog:@"[%@:%@] %@", [m objectForKey:@"sourceURL"], [m objectForKey:@"lineNumber"], [m objectForKey:@"message"]];
}


@end
