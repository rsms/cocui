#import <JavaScriptCore/JavaScriptCore.h>

#define CUJS_EXPOSE_THIS_CLASS\
	+ (BOOL)isKeyExcludedFromWebScript:(const char *)name { return NO; }\
	+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel { return NO; }

#define CUJS_TRANSPOND_NAMES_PLAIN\
	+ (NSString *)webScriptNameForSelector:(SEL)sel {\
		NSString *s = NSStringFromSelector(sel);\
		s = [s stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];\
		s = [s stringByReplacingOccurrencesOfString:@"_" withString:@"$"];\
		s = [s stringByReplacingOccurrencesOfString:@":" withString:@"_"];\
		return s;\
	}

#define CUJS_EXPOSE_CLASS(_clsname_)\
	@implementation _clsname_ (EVJSExposure)\
	CUJS_EXPOSE_THIS_CLASS\
	@end

#define CUJS_FORWARD_INVOCATION_TO(_membername_)\
	- (id)invokeUndefinedMethodFromWebScript:(NSString *)name withArguments:(NSArray *)args {\
		return cu_js_forward_invocation(_membername_, name, args, NO);\
	}

#define CUJS_FORWARD_INVOCATION_STRICTLY_TO(_membername_)\
	- (id)invokeUndefinedMethodFromWebScript:(NSString *)name withArguments:(NSArray *)args {\
		return cu_js_forward_invocation(_membername_, name, args, YES);\
	}

// forward objc notification/delegate call as Event on document in script env

#define CUJS_DISPATCH_EVENT(_name_, _domdoc_) do {\
	DOMDocument *d = (_domdoc_);\
	if (d) {\
		DOMEvent *ev = [d createEvent:@"Event"];\
		[ev initEvent:@"" #_name_ canBubbleArg:NO cancelableArg:YES];\
		[d dispatchEvent:ev];\
	}\
} while(0)

#define CUJS_FORWARD_NOTIFICATION_IM(_name_, _domdoc_)\
	- (void)_name_:(NSNotification *)notification {\
		CUJS_DISPATCH_EVENT(_name_, _domdoc_);\
	}

#define CUJS_THROW(NSString_format, ... )\
	[WebScriptObject throwException:[NSString stringWithFormat:NSString_format, ##__VA_ARGS__]]


id cu_js_forward_invocation(id target, NSString *name, NSArray *args, BOOL strict);

#import "EVPoint.h"
#import "EVSize.h"
#import "EVRect.h"

