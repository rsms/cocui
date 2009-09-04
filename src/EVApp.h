#import "EVWebView.h"
#import "EVJSBridge.h"

@interface EVApp : NSApplication {
	IBOutlet NSWindow *mainWindow;
	IBOutlet EVWebView *webView;
	EVJSBridge *ev;
}

@end
