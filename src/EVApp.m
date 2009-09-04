#import "EVApp.h"

#define kEVJavascriptNamespace @"ev"

@implementation EVApp

- (id)init {
	[super init];
	[self setDelegate:self];
	
	ev = [[EVJSBridge alloc] init];
	ev.version = @"0.0.1";
	
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// set properties on ev
	ev.window = mainWindow;
	ev.application = self;
	
	// expose ev namespace in javascript
	[[webView windowScriptObject] setValue:ev forKey:kEVJavascriptNamespace];
	
	// load index.html
	NSURL *indexURL = [[NSURL alloc] 
					   initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@""]
					   isDirectory:false];
#if 0
	indexURL = [[NSURL alloc] 
				initFileURLWithPath:@"/Users/rasmus/src/cocojs/resources/index.html"
				isDirectory:false];
	
#endif
	NSLog(@"indexURL = %@", indexURL);
	NSURLRequest *req = [NSURLRequest requestWithURL:indexURL];
	[[webView mainFrame] loadRequest:req];
}

#if DEBUG
- (void)_debugCheckReload {
	// periodically check if index.html have been modified and if so reload
}
#endif

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
	// the script object need to be updated before every page load
	[[webView windowScriptObject] setValue:ev forKey:kEVJavascriptNamespace];
	NSLog(@"loading");
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	//if (frame == [webView mainFrame])
	//	[mainWindow setTitle:[[webView mainFrame] ti ];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	NSLog(@"ALERT [%@] %@", frame, message);
	//NSBeginInformationalAlertSheet(@"Alert", nil, nil, nil, [sender window], nil, NULL, NULL, NULL, message);
}

- (void)webView:(WebView *)webv addMessageToConsole:(NSDictionary *)message {
	NSNumber *lineNumber = [message objectForKey:@"lineNumber"];
	id msg = [message objectForKey:@"message"];
	NSURL *sourceURL = [message objectForKey:@"sourceURL"];
	NSLog(@"[%@:%@] %@", sourceURL, lineNumber, msg);
}


@end
