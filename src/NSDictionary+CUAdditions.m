#import "NSDictionary+CUAdditions.h"

@implementation NSDictionary (CUAdditions)

- (NSRect)updateRect:(NSRect)rect {
	NSDictionary *d;
	if ((d = [self objectForKey:@"origin"]) && [d respondsToSelector:@selector(updatePoint:)])
		rect.origin = [d updatePoint:rect.origin];
	if ((d = [self objectForKey:@"size"]) && [d respondsToSelector:@selector(updateSize:)])
		rect.size = [d updateSize:rect.size];
	return rect;
}

- (NSPoint)updatePoint:(NSPoint)point {
	NSNumber *n;
	if ((n = [self objectForKey:@"x"]) && [n respondsToSelector:@selector(floatValue)])
		point.x = [n floatValue];
	if ((n = [self objectForKey:@"y"]) && [n respondsToSelector:@selector(floatValue)])
		point.y = [n floatValue];
	return point;
}

- (NSSize)updateSize:(NSSize)size {
	NSNumber *n;
	if ((n = [self objectForKey:@"width"]) && [n respondsToSelector:@selector(floatValue)])
		size.width = [n floatValue];
	if ((n = [self objectForKey:@"height"]) && [n respondsToSelector:@selector(floatValue)])
		size.height = [n floatValue];
	return size;
}

@end
