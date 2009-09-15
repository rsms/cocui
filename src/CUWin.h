#import "CUWindow.h"
#import "EVRect.h"

/*
 Exposed as "Win" in window script contexts and represents the window.
 Because we can not simply override library-standard methods in the real window,
 we use this proxy object.
 */

@interface CUWin : NSObject {
	CUWindow *win;
	CGDirectDisplayID fullscreen; // -1 when not in fullscreen mode
	
	// Not actually used, but here to comply with KVC in the WebScript environment:
	char level;
	char shadow;
	char window;
	char document;
	char frame;
	
@protected
	NSInteger _levelBeforeFullscreen;
	NSRect _frameBeforeFullscreen;
}

@property(assign) NSString *level;
@property(assign) BOOL shadow;
@property(assign) BOOL fullscreen;
@property(readonly) WebScriptObject *window;
@property(readonly) WebScriptObject *document;
@property(assign) EVRect *frame;

-(id)initWithWindow:(CUWindow *)window;

@end
