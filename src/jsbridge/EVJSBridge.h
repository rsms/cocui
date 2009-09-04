@interface EVJSBridge : NSObject {
	NSString *version;
	id application;
	id window;
}

@property(assign) NSString *version;
@property(assign) id application;
@property(assign) id window;

@end
