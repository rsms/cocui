#import "CUApp.h"

@interface CUWindow : NSWindow {
	CUApp *app;
	WebView *webView;
}

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask defer:(BOOL)defer preferences:(WebPreferences *)webPrefs app:(CUApp *)app;
-(void)loadURL:(NSURL *)url;

@end
