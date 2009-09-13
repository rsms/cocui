#import "EVJSApp.h"
#import "jsbridge.h"

@implementation EVJSApp

@synthesize version, app, window, defaults, defaultsController;

// callbacks
@synthesize onOpenFiles;

EVJS_EXPOSE_THIS_CLASS
EVJS_TRANSPOND_NAMES_PLAIN

-(void)terminate {
	[app terminate:self];
}

@end
