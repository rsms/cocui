#import "CUManagerApp.h"
#import "IconFamily.h"

@implementation CUManagerApp

- (void)awakeFromNib {
	defaults = [NSUserDefaults standardUserDefaults];
	documentTypes = [NSMutableArray array];
	
	NSString *locPath = [defaults stringForKey:@"locationPath"];
	if (!locPath)
		locPath = [NSHomeDirectory() stringByAppendingString:@"/Documents"];
	[locationPath setURL:[[NSURL alloc] initFileURLWithPath:locPath isDirectory:YES]];
	
	if (![icon image]) {
		icon.imageURL = nil;
		[icon setImage:[NSImage imageNamed:@"NSApplicationIcon"]];
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// write defaults
	[defaults setObject:[[locationPath URL] path] forKey:@"locationPath"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"started");
}

-(IBAction)create:(id)sender {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSMutableString *errorMessage = [NSMutableString string];
	NSError *e = nil;
	NSData *d;
	BOOL isDir = YES;
	NSString *sname, *suti;
	
	sname = [[name stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	suti = [[uti stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSLog(@"create\n name %@\n uti %@\n icon %@\n location %@\n hasDockIcon %@\n doctypes %@",
		  sname, suti, icon.imageURL, [locationPath stringValue], hasDockIcon, documentTypes);
	
	if (!sname || ![sname length])
		[errorMessage appendString:@"• Name can not be empty.\n"];
	if (!suti || ![suti length])
		[errorMessage appendString:@"• UTI can not be empty.\n"];
	else if (!locationPath)
		[errorMessage appendString:@"• No location have been choosen.\n"];
	
	// incomplete?
	if ([errorMessage length]) {
		NSAlert* alert = [NSAlert new];
		[alert setMessageText:     @"One or more fields are missing"];
		[alert setInformativeText: errorMessage];
		[alert runModal];
		return; // abort
	}
	
	// create
	
	if (![[locationPath URL] isFileURL]) {
		[[NSAlert alertWithMessageText:@"Location must be local" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The project location must be on your local computer. %@ is not a file-URL.", [locationPath URL]] runModal];
		return; // abort
	}
	
	NSString *basedir = [[[locationPath URL] path] stringByStandardizingPath];
	basedir = [basedir stringByAppendingPathComponent:[[sname lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
	
	if ([fm fileExistsAtPath:basedir]) {
		NSLog(@"directory %@ already exists", basedir);
		[[NSAlert alertWithMessageText:@"Project already exists" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The directory %@ already exists", basedir] runModal];
		return; // abort
	}
	
	e = nil;
	if (![fm createDirectoryAtPath:basedir withIntermediateDirectories:YES attributes:nil error:&e]) {
		NSLog(@"failed to create direcory at %@", basedir);
		[[NSAlert alertWithError:e] runModal];
		return; // abort
	}
	NSLog(@"created directory %@", basedir);
	
	NSString *tplAppdir = [[NSBundle mainBundle] resourcePath];
	tplAppdir = [tplAppdir stringByAppendingPathComponent:@"Template.app"];
	
	if (![fm fileExistsAtPath:tplAppdir isDirectory:&isDir] || !isDir) {
		[[NSAlert alertWithMessageText:@"Template app not found" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The template app bundle could not be found at %@", tplAppdir] runModal];
		return; // abort
	}
	
	NSString *appdir = [basedir stringByAppendingPathComponent:sname];
	appdir = [appdir stringByAppendingPathExtension:@"app"];
	NSString *respath = [appdir stringByAppendingPathComponent:@"Contents/Resources"];
	
	e = nil;
	if (![fm copyItemAtPath:tplAppdir toPath:appdir error:&e]) {
		NSLog(@"failed to copy app to %@", appdir);
		[[NSAlert alertWithError:e] runModal];
		return; // abort
	}
	NSLog(@"copied template app from %@ to %@", tplAppdir, appdir);
	
	// update Info.plist
	NSString *infoPlistPath = [appdir stringByAppendingPathComponent:@"Contents/Info.plist"];
	NSMutableDictionary *infoPlist = [NSMutableDictionary dictionaryWithContentsOfFile:infoPlistPath];
	
	[infoPlist setObject:suti forKey:@"CFBundleIdentifier"];
	[infoPlist setObject:sname forKey:@"CFBundleName"];
	
	if (![hasDockIcon intValue])
		[infoPlist setObject:[NSNumber numberWithBool:YES] forKey:@"NSUIElement"];
	
	// icon
	[infoPlist removeObjectForKey:@"CFBundleIconFile"];
	if (icon.imageURL) {
		NSString *icopath = [respath stringByAppendingPathComponent:[[icon.imageURL path] lastPathComponent]];
		icopath = [[icopath stringByDeletingPathExtension] stringByAppendingPathExtension:@"icns"];
		NSImage *ico = [[NSImage alloc] initWithContentsOfURL:icon.imageURL];
		IconFamily* iconFamily = [IconFamily iconFamilyWithThumbnailsOfImage:ico usingImageInterpolation:NSImageInterpolationHigh];
		if ([iconFamily writeToFile:icopath])
			[infoPlist setObject:[[icopath lastPathComponent] stringByDeletingPathExtension] forKey:@"CFBundleIconFile"];
		else
			NSLog(@"failed to write icon file");
	}
	
	[infoPlist removeObjectForKey:@"CFBundleDocumentTypes"];
	
	if ([documentTypes count]) {
		NSString *s;
		NSArray *a;
		NSMutableArray *types = [NSMutableArray arrayWithCapacity:[documentTypes count]];
		
		for (NSMutableDictionary *item in documentTypes) {
			NSMutableDictionary *type = [NSMutableDictionary dictionary];
			
			s = [item objectForKey:@"name"];
			if (s && [s length])
				[type setObject:s forKey:@"CFBundleTypeName"];
			
			s = [item objectForKey:@"icon"];
			if (s && [s length])
				[type setObject:s forKey:@"CFBundleTypeIconFile"];
			
			if ((s = [item objectForKey:@"extensions"])) {
				a = [s componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if ([a count])
					[type setObject:a forKey:@"CFBundleTypeExtensions"];
			}
			
			if ((s = [item objectForKey:@"mimeTypes"])) {
				a = [s componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if ([a count])
					[type setObject:a forKey:@"CFBundleTypeMIMETypes"];
			}
			
			if ((s = [item objectForKey:@"utis"])) {
				a = [s componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if ([a count])
					[type setObject:a forKey:@"LSItemContentTypes"];
			}
			
			s = [item objectForKey:@"role"];
			if (s && [s length])
				[type setObject:s forKey:@"CFBundleTypeRole"];
			
			[types addObject:type];
		}
		
		if ([types count])
			[infoPlist setObject:types forKey:@"CFBundleDocumentTypes"];
	}
	
	// write Info.plist
	NSString *errstr;
	d = [NSPropertyListSerialization dataFromPropertyList:infoPlist format:NSPropertyListXMLFormat_v1_0 errorDescription:&errstr];
	if (!d) {
		NSLog(@"failed to update %@: %@", infoPlistPath, errstr);
		[[NSAlert alertWithMessageText:@"Failed to update Info.plist" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", errstr] runModal];
	}
	else {
		[d writeToFile:infoPlistPath atomically:YES];
		NSLog(@"updated %@", infoPlistPath);
	}
	
	// Set DevelopmentMode in defaults
	[defaults setPersistentDomain:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"DevelopmentMode"] forName:suti];
	
	// make symlink to resources
	NSString *ln = [basedir stringByAppendingPathComponent:@"Resources"];
	NSString *t = respath;
	if (![fm createSymbolicLinkAtPath:ln withDestinationPath:t error:&e]) {
		NSLog(@"failed to create symbolic link at %@ pointing to %@", ln, t);
		[[NSAlert alertWithError:e] runModal];
	}
	ln = [basedir stringByAppendingPathComponent:@"index.html"];
	t = [respath stringByAppendingPathComponent:@"index.html"];
	if (![fm createSymbolicLinkAtPath:ln withDestinationPath:t error:&e]) {
		NSLog(@"failed to create symbolic link at %@ pointing to %@", ln, t);
		[[NSAlert alertWithError:e] runModal];
	}
	
	// reveal in finder
	[[NSWorkspace sharedWorkspace] openFile:basedir withApplication:@"Finder"];
	
	// launch new app
	[[NSWorkspace sharedWorkspace] openFile:appdir];
	
	// edit index.html
	NSString *indexhtml = [respath stringByAppendingPathComponent:@"index.html"];
	if ([[NSWorkspace sharedWorkspace] openFile:respath withApplication:@"TextMate" andDeactivate:YES]) {
		[[NSWorkspace sharedWorkspace] openFile:indexhtml withApplication:@"TextMate"];
	}
	else {
		[[NSWorkspace sharedWorkspace] openFile:indexhtml withApplication:@"SubEthaEdit" andDeactivate:YES];
	}
	
	[self clear:self];
}


-(IBAction)clear:(id)sender {
	[name setStringValue:@""];
	[uti setStringValue:@""];
	[documentTypes removeAllObjects];
	[documentTypesTable setNeedsDisplay];
	icon.imageURL = nil;
	[icon setImage:[NSImage imageNamed:@"NSApplicationIcon"]];
}

@end
