#import "EVApp.h"
#import "WebScriptObject+EVJS.h"
#import "jsbridge.h"

#import "webkit-private/WebInspector.h"
#import "webkit-private/WebInspectorWindowController.h"

//#define WITH_FSCRIPT 1
#if WITH_FSCRIPT
	#import <FScript/FScript.h>
#endif

EVApp *g_app = NULL;


@implementation WebInspectorWindowController (OverrideCloseAction)
// This is a fix for the broken WebInspector which window can not be closed once we have opened it
- (BOOL)windowShouldClose:(id)window {
	[window orderOut:self];
	return NO;
}
@end


@implementation EVApp

@synthesize developmentMode;

+ (EVApp *)instance {
	if (!g_app)
		[[EVApp alloc] init];
	return g_app;
}


- (id)init {
	NSLog(@"-[EVApp init]");
	[super init];
	g_app = self;
	[self setDelegate:self];
	
	WebPreferences *preferences = [WebPreferences standardPreferences];
	[preferences setUserStyleSheetLocation:[[NSURL alloc] 
											initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"css"]
											isDirectory:false]];
	[preferences setUserStyleSheetEnabled:YES];
	
	jsapp = [[CUApp alloc] initWithWebPreferences:preferences];
	jsapp.version = @"0.0.1"; // todo read from Info.plist
	jsapp.defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	jsapp.defaults = [jsapp.defaultsController defaults];
	
	// development mode
	developmentMode = [jsapp.defaults boolForKey:@"DevelopmentMode"];
	[jsapp.defaults setBool:developmentMode forKey:@"WebKitDeveloperExtras"];
	if (developmentMode) {
		[jsapp.defaults setBool:NO forKey:@"WebKitInspectorAttached"];
		[jsapp.defaults setBool:YES forKey:@"WebKit Web Inspector Setting - resourceTrackingEnabled"];
	}
	else {
		// write it so people can find it when looking in Info.plist
		[jsapp.defaults setBool:NO forKey:@"DevelopmentMode"];
		[jsapp.defaults removeObjectForKey:@"WebKitDeveloperExtras"];
	}
	
	return self;
}

- (void)awakeFromNib {
	if (!g_app)
		g_app = self;
	if (developmentMode) {
		NSRange er;
		logTextAttrs = [[logTextView textStorage] attributesAtIndex:0 effectiveRange:&er];
		[[logTextView textStorage] deleteCharactersInRange:NSMakeRange(0, [[logTextView textStorage] length])];
		[logTextView setTextContainerInset:NSMakeSize(2.0, 2.0)];
		[self dlog:@"starting in development mode"];
	}
	else {
		[[NSApp mainMenu] removeItem:[[NSApp mainMenu] itemWithTitle:@"Develop"]];
		//[logPanel release];
		logPanel = nil;
	}
}


- (void)dlog:(NSString *)format, ... {
	va_list args;
	va_start(args, format);
	[self dlog:format args:args];
	va_end(args);
}


- (void)dlog:(NSString *)format args:(va_list)args {
	if (developmentMode) {
		format = [[NSString alloc] initWithFormat:format arguments:args];
		[logTextView insertText:[[NSAttributedString alloc] 
								 initWithString:[NSString stringWithFormat:@"%@ %@\n", [NSDate date], format]
								 attributes:logTextAttrs]];
	}
	NSLogv(format, args);
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// F-Script
#if WITH_FSCRIPT
	[[NSApp mainMenu] addItem:[[FScriptMenuItem alloc] init]];
#endif
	[self loadMainScript];
}


-(void)loadMainScript {
	NSString *mainsrc, *errDesc, *mainpath = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"js"];
	NSStringEncoding charenc;
	NSError *err = nil;
	
	while (1) {
		mainsrc = [NSString stringWithContentsOfFile:mainpath usedEncoding:&charenc error:&err];
		if (!mainsrc || err) {
			[[NSAlert alertWithError:err] runModal];
			[NSApp terminate:self];
		}
		[self dlog:@"executing %@ with character encoding %d", mainpath, charenc];
		if ([jsapp evaluateWebScript:mainsrc errorDesc:&errDesc])
			break;
		[self dlog:@"%@ failed to execute: %@", mainpath, errDesc];
		NSInteger buttonClicked = [[NSAlert alertWithMessageText:@"Failed to start application" 
												   defaultButton:@"Reload and Retry" 
												 alternateButton:@"Quit" 
													 otherButton:nil 
									   informativeTextWithFormat:@"%@\n\nIn %@", errDesc, mainpath] runModal];
		if (buttonClicked == 0) {
			[NSApp terminate:self];
			break;
		}
	}
}


-(WebInspector *)webInspector {
	if (!webInspector)
		webInspector = [[NSClassFromString(@"WebInspector") alloc] initWithWebView:jsapp.webView];
	if (!webInspectorWindowController)
		webInspectorWindowController = [[NSClassFromString(@"WebInspectorWindowController") alloc] initWithInspectedWebView:jsapp.webView];
	return webInspector;
}


#pragma mark -
#pragma mark UI actions


-(WebInspector *)_frontmostWebInspector {
	NSWindow *win = [self keyWindow];
	NSLog(@"win = %@", win);
	if (win && [win respondsToSelector:@selector(webInspector)])
		return [(id)win webInspector];
	return [self webInspector];
}

-(IBAction)showInspector:(id)sender {
	[self dlog:@"displaying web inspector"];
	[[self _frontmostWebInspector] show:webInspectorWindowController];
}

-(IBAction)showConsole:(id)sender {
	[self dlog:@"displaying web inspector with console"];
	[[self _frontmostWebInspector] showConsole:webInspectorWindowController];
}

-(IBAction)showMainConsole:(id)sender {
	[self dlog:@"displaying web inspector with console"];
	[[self webInspector] showConsole:webInspectorWindowController];
}

-(IBAction)reloadApp:(id)sender {
	[self dlog:@"reloading main.js"];
	[self loadMainScript];
}


#pragma mark -
#pragma mark NSApplication delegate methods

// forward notification as js events on document

#define _DOMDOC [[jsapp.webView mainFrame] DOMDocument]
CUJS_FORWARD_NOTIFICATION_IM(applicationWillBecomeActive, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationDidBecomeActive, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationWillResignActive, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationDidResignActive, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationWillTerminate, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationWillHide, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationDidHide, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationWillUnhide, _DOMDOC)
CUJS_FORWARD_NOTIFICATION_IM(applicationDidUnhide, _DOMDOC)
#undef _DOMDOC


- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	NSLog(@"openFiles: %@", filenames);
	// call onOpenFiles callback, if present
	if (jsapp.onOpenFiles)
		[jsapp.onOpenFiles invokeWithArguments:filenames inContext:[[jsapp.webView mainFrame] globalContext]];
}



@end
