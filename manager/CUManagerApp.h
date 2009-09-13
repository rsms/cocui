#import "CUImageView.h"

@interface CUManagerApp : NSObject {
	// required
	IBOutlet NSTextField *name;
	IBOutlet NSTextField *uti;
	IBOutlet NSPathControl *locationPath;
	
	// optional
	IBOutlet CUImageView *icon;
	IBOutlet NSMutableArray *documentTypes;
	IBOutlet NSTableView *documentTypesTable;
	
	// advanced
	IBOutlet NSButton *hasDockIcon; // if false, set NSUIElement to YES
	
	// controls
	IBOutlet NSButton *createButton;
	
	NSUserDefaults *defaults;
}

-(IBAction)create:(id)sender;
-(IBAction)clear:(id)sender;

@end
