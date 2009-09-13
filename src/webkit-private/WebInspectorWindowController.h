#import <WebKit/WebView.h>

@class WebNodeHighlight;

@interface WebInspectorWindowController : NSWindowController /*<NSWindowDelegate>*/
{
	WebView *_inspectedWebView;
	WebView *_webView;
	WebNodeHighlight *_currentHighlight;
	BOOL _attachedToInspectedWebView;
	BOOL _shouldAttach;
	BOOL _visible;
	BOOL _movingWindows;
}

- (id)init;
- (id)initWithInspectedWebView:(id)webView;
- (void)dealloc;
- (BOOL)inspectorVisible;
- (id)webView;
- (id)window;
- (BOOL)windowShouldClose:(id)arg1;
- (void)close;
- (void)showWindow:(id)arg1;
- (void)attach; // attach inside window
- (void)detach; // detach to separate window
- (void)setAttachedWindowHeight:(unsigned int)arg1;
- (void)highlightNode:(id)arg1;
- (void)hideHighlight;
- (void)didAttachWebNodeHighlight:(id)arg1;
- (void)willDetachWebNodeHighlight:(id)arg1;
- (unsigned long long)webView:(id)arg1 dragDestinationActionMaskForDraggingInfo:(id)arg2;
- (void)showWebInspector:(id)arg1;
- (void)showErrorConsole:(id)arg1;
- (void)toggleDebuggingJavaScript:(id)arg1;
- (void)toggleProfilingJavaScript:(id)arg1;
- (BOOL)validateUserInterfaceItem:(id)arg1;

@end
