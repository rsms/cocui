#import "EVWebView.h"
#import "CUApp.h"

@class WebInspector, WebInspectorWindowController, EVApp;

extern EVApp *g_app; // global instance of application

@interface EVApp : NSApplication {
	CUApp *jsapp; // "App" namespace exposed in Javascript
	BOOL developmentMode;
	
	IBOutlet NSWindow *logPanel;
	IBOutlet NSTextView *logTextView;
	NSDictionary *logTextAttrs;
	
	WebInspector *webInspector;
	WebInspectorWindowController *webInspectorWindowController;
}

@property(readonly) BOOL developmentMode;

+ (EVApp *)instance;

-(void)loadMainScript;

-(IBAction)showInspector:(id)sender; // for frontmost win or main if no wins
-(IBAction)showConsole:(id)sender; // for frontmost win or main if no wins
-(IBAction)showMainConsole:(id)sender;
-(IBAction)reloadApp:(id)sender;

-(WebInspector *)webInspector;

-(void)dlog:(NSString *)format, ...;
-(void)dlog:(NSString *)format args:(va_list)args;

@end
