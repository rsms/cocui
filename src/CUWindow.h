#import "CUApp.h"

extern const char *kCUWindowLevelNames[];
extern const CGWindowLevelKey kCUWindowLevelKeys[];

@class WebInspector, WebInspectorWindowController, CUWin;

@interface CUWindow : NSWindow {
	CUWin *win;
	CUApp *app;
	WebView *webView;
	WebInspector *webInspector;
	WebInspectorWindowController *webInspectorWindowController;
}

@property(readonly) WebView *webView;
@property(readonly) CUApp *app;
@property(readonly) CUWin *win;

+(CGWindowLevelKey)windowLevelKeyFromNameOrNumber:(id)s;
+(const char *)windowLevelNameForLevel:(CGWindowLevel)level;

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask defer:(BOOL)defer preferences:(WebPreferences *)webPrefs app:(CUApp *)app;
-(void)loadURL:(NSURL *)url;

@end
