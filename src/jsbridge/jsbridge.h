// expose most of foundation and appkit
// TODO alot...

#define EVJS_EXPOSE_THIS_CLASS\
	+ (BOOL)isKeyExcludedFromWebScript:(const char *)name { return NO; }\
	+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel { return NO; }

#define EVJS_TRANSPOND_NAMES_PLAIN\
	+ (NSString *)webScriptNameForSelector:(SEL)sel {\
	NSString *s = NSStringFromSelector(sel);\
	s = [s stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];\
	s = [s stringByReplacingOccurrencesOfString:@":" withString:@"_"];\
	return s;\
	}

#define EVJS_EXPOSE_CLASS(_clsname_)\
	@implementation _clsname_ (EVJSExposure)\
	EVJS_EXPOSE_THIS_CLASS\
	@end

#import "EVPoint.h"
#import "EVSize.h"
#import "EVRect.h"

