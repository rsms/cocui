#import "EVWebView.h"
#import "EVJSApp.h"

@class WebInspector, WebInspectorWindowController;

@interface EVApp : NSApplication {
	EVJSApp *jsapp; // "App" namespace exposed in Javascript
	BOOL developmentMode;
	JSContextRef jctx; // global scripting context
	IBOutlet NSWindow *mainWindow;
	IBOutlet EVWebView *webView;
	
	IBOutlet NSWindow *logPanel;
	IBOutlet NSTextView *logTextView;
	NSDictionary *logTextAttrs;
	
	WebInspector *webInspector;
	WebInspectorWindowController *webInspectorWindowController;
}

-(WebInspector *)webInspector;
-(IBAction)showInspector:(id)sender;
-(IBAction)showConsole:(id)sender;
-(void)dlog:(NSString *)format, ...;
-(void)dlog:(NSString *)format args:(va_list)args;

@end
