@class WebView;

@interface WebInspector : NSObject
{
    WebView *_webView;
}

- (id)initWithWebView:(id)arg1;
- (void)webViewClosed;
- (void)show:(id)arg1;
- (void)showConsole:(id)arg1;
- (void)showTimeline:(id)arg1;
- (BOOL)isDebuggingJavaScript;
- (void)toggleDebuggingJavaScript:(id)arg1;
- (void)startDebuggingJavaScript:(id)arg1;
- (void)stopDebuggingJavaScript:(id)arg1;
- (BOOL)isProfilingJavaScript;
- (void)toggleProfilingJavaScript:(id)arg1;
- (void)startProfilingJavaScript:(id)arg1;
- (void)stopProfilingJavaScript:(id)arg1;
- (BOOL)isJavaScriptProfilingEnabled;
- (void)setJavaScriptProfilingEnabled:(BOOL)arg1;
- (void)close:(id)arg1;
- (void)attach:(id)arg1;
- (void)detach:(id)arg1;

@end
