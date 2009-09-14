#import "CUApp.h"

@class WebInspector, WebInspectorWindowController;

@interface CUWindow : NSWindow {
	CUApp *app;
	WebView *webView;
	WebInspector *webInspector;
	WebInspectorWindowController *webInspectorWindowController;
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask defer:(BOOL)defer preferences:(WebPreferences *)webPrefs app:(CUApp *)app;
-(void)loadURL:(NSURL *)url;

@end
