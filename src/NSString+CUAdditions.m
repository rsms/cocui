#import "NSString+CUAdditions.h"

@implementation NSString (CUAdditions)

- (NSString *)JSONRepresentation
{
	NSMutableString *jsonString = [[NSMutableString alloc] init];
	[jsonString appendString:@"\""];
	
	// Build the result one character at a time, inserting escaped characters as necessary
	int i;
	unichar nextChar;
	for (i = 0; i < [self length]; i++) {
		nextChar = [self characterAtIndex:i];
		switch (nextChar) {
			case '\"':
				[jsonString appendString:@"\\\""];
				break;
			case '\\':
				[jsonString appendString:@"\\n"];
				break;
			case '/':
				[jsonString appendString:@"\\/"];
				break;
			case '\b':
				[jsonString appendString:@"\\b"];
				break;
			case '\f':
				[jsonString appendString:@"\\f"];
				break;
			case '\n':
				[jsonString appendString:@"\\n"];
				break;
			case '\r':
				[jsonString appendString:@"\\r"];
				break;
			case '\t':
				[jsonString appendString:@"\\t"];
				break;
			// note: maybe encode unicode characters? Spec allows raw unicode.
			default:
				if (nextChar < 32) // all ctrl chars must be escaped
					[jsonString appendString:[NSString stringWithFormat:@"\\u%04x", nextChar]];
				else
					[jsonString appendString:[NSString stringWithCharacters:&nextChar length:1]];
				break;
		}
	}
	[jsonString appendString:@"\""];
	return [jsonString autorelease];
}


@end
