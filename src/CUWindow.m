#import "EVApp.h"
#import "CUWin.h"
#import "CUWindow.h"
#import "jsbridge.h"

#import "webkit-private/WebInspector.h"
#import "webkit-private/WebInspectorWindowController.h"

const char *kCUWindowLevelNames[] = {
	"Base",
	"Minimum",
	"Desktop",
	"BackstopMenu",
	"Normal",
	"Floating",
	"TornOffMenu",
	"Dock",
	"MainMenu",
	"Status",
	"ModalPanel",
	"PopUpMenu",
	"Dragging",
	"ScreenSaver",
	"Maximum",
	"Overlay",
	"Help",
	"Utility",
	"DesktopIcon",
	"Cursor",
	"AssistiveTechHigh"
};

const CGWindowLevelKey kCUWindowLevelKeys[] = {
	kCGBaseWindowLevelKey,
	kCGMinimumWindowLevelKey,
	kCGDesktopWindowLevelKey,
	kCGBackstopMenuLevelKey,
	kCGNormalWindowLevelKey,
	kCGFloatingWindowLevelKey,
	kCGTornOffMenuWindowLevelKey,
	kCGDockWindowLevelKey,
	kCGMainMenuWindowLevelKey,
	kCGStatusWindowLevelKey,
	kCGModalPanelWindowLevelKey,
	kCGPopUpMenuWindowLevelKey,
	kCGDraggingWindowLevelKey,
	kCGScreenSaverWindowLevelKey,
	kCGMaximumWindowLevelKey,
	kCGOverlayWindowLevelKey,
	kCGHelpWindowLevelKey,
	kCGUtilityWindowLevelKey,
	kCGDesktopIconWindowLevelKey,
	kCGCursorWindowLevelKey,
	kCGAssistiveTechHighWindowLevelKey
};

@implementation CUWindow

CUJS_EXPOSE_THIS_CLASS
CUJS_TRANSPOND_NAMES_PLAIN

@synthesize webView, app, win;


+(const char *)windowLevelNameForLevel:(CGWindowLevel)level {
	if (level >= 0 && level < kCGNumberOfWindowLevelKeys) {
		for (int i=0; i<kCGNumberOfWindowLevelKeys; i++)
			if (CGWindowLevelForKey(kCUWindowLevelKeys[i]) == level)
				return kCUWindowLevelNames[i];
	}
	return NULL;
}


+(CGWindowLevelKey)windowLevelKeyFromNameOrNumber:(id)s {
	if ([s respondsToSelector:@selector(UTF8String)]) {
		const char *utf8pch = [s UTF8String];
		for (int i=0; i<kCGNumberOfWindowLevelKeys; i++) {
			if (strcasecmp(utf8pch, kCUWindowLevelNames[i]) == 0) {
				return kCUWindowLevelKeys[i];
			}
		}
	}
	else if ([s respondsToSelector:@selector(intValue)]) {
		int d = [s intValue];
		if (d >= kCGNumberOfWindowLevelKeys)
			d = kCGNumberOfWindowLevelKeys-1;
		return d;
	}
	return -1;
}


-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask defer:(BOOL)defer preferences:(WebPreferences *)webPrefs app:(CUApp *)_app
{
	app = _app;
	win = [[CUWin alloc] initWithWindow:self];
	self = [self initWithContentRect:contentRect styleMask:styleMask backing:NSBackingStoreBuffered defer:defer];
	webView = [[WebView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 10.0, 10.0) frameName:@"main" groupName:@"app"];
	[webView setFrameLoadDelegate:self];
	[webView setUIDelegate:self];
	[webView setPreferences:webPrefs];
	[webView setDrawsBackground:NO];
	webInspector = nil;
	webInspectorWindowController = nil;
	[self setContentView:webView];
	[self setDelegate:self];
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
#pragma mark NSApplication delegate methods

// forward notification as js events on document

#define _DOMDOC [[webView mainFrame] DOMDocument]
CUJS_FORWARD_NOTIFICATION_IM(windowDidBecomeKey, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidBecomeMain, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidChangeScreen, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidDeminiaturize, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidEndSheet, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidExpose, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidMiniaturize, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidMove, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidResignKey, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidResignMain, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowDidResize, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowWillBeginSheet, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowWillClose, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowWillMiniaturize, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(windowWillMove, _DOMDOC)
#undef _DOMDOC


#pragma mark -
#pragma mark WebFrameLoadDelegate methods

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
	// expose our objects in javascript
	WebScriptObject *root = [webView windowScriptObject];
	[root setValue:app forKey:kCUAppWebScriptNamespace];
	[root setValue:win forKey:kCUWindowWebScriptNamespace];
	
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


-(BOOL)canBecomeKeyWindow {
	return YES;
}


/*- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
 return defaultMenuItems;
 }*/


// Unofficial:

- (void)webView:(WebView *)sender addMessageToConsole:(NSDictionary *)m {
	[g_app dlog:@"[%@:%@] %@", [m objectForKey:@"sourceURL"], [m objectForKey:@"lineNumber"], [m objectForKey:@"message"]];
}


@end
