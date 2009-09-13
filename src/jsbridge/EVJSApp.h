@interface EVJSApp : NSObject {
	NSString *version;
	id app;
	id window;
	NSUserDefaultsController *defaultsController;
	NSUserDefaults *defaults;
	
	// Callbacks
	WebScriptObject *onOpenFiles;
}

@property(assign) NSString *version;
@property(assign) id app;
@property(assign) id window;
@property(assign) NSUserDefaultsController *defaultsController;
@property(assign) NSUserDefaults *defaults;

// void onOpenFiles([string filename[, ..]])
@property(assign) WebScriptObject *onOpenFiles;

@end
