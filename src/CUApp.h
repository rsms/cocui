@interface CUApp : NSObject {
	NSString *version;
	NSUserDefaultsController *defaultsController;
	NSUserDefaults *defaults;
	
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

// void onOpenFiles([string filename[, ..]])
@property(assign) WebScriptObject *onOpenFiles;

@property(readonly) WebView *webView;

-(id)initWithWebPreferences:(WebPreferences *)preferences;
-(id)evaluateWebScript:(NSString *)js errorDesc:(NSString **)errdesc;
-(void)terminate;

@end
