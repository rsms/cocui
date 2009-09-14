@class CUWin;

@interface CUApp : NSObject {
	NSString *version;
	NSUserDefaultsController *defaultsController;
	NSUserDefaults *defaults;
	CGDirectDisplayID fullscreen; // -1 when not in fullscreen mode
	
	// Callbacks
	WebScriptObject *onOpenFiles;
	
	// WebView object
	WebView *webView;
	
@protected
	WebPreferences *_webPrefs;
}

@property(assign) NSString *version;
@property(assign) NSUserDefaultsController *defaultsController;
@property(assign) NSUserDefaults *defaults;
@property(assign) BOOL fullscreen;

// void onOpenFiles([string filename[, ..]])
@property(assign) WebScriptObject *onOpenFiles;

@property(readonly) WebView *webView;

-(id)initWithWebPreferences:(WebPreferences *)preferences;
-(id)evaluateWebScript:(NSString *)js errorDesc:(NSString **)errdesc;
-(void)terminate;

-(CUWin *)createWindow:(WebScriptObject *)jsargs;


// Enter/exit fullscreen:
// mostly here for other objc classes to use for getting success status.
// Scripts should use the "fullscreen" property.
-(BOOL)enterFullscreen:(CGDirectDisplayID)screenID;
-(BOOL)exitFullscreen:(CGDirectDisplayID)screenID;
-(CGDirectDisplayID)exitFullscreen;

@end
