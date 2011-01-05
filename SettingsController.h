//
//  SettingsController.h
//  focus
//
//  Created by Ben McRedmond on 24/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsController : NSObject <NSTableViewDataSource> {
    IBOutlet NSWindow *settingsWindow;
    IBOutlet NSTextField *defaultFocusMinutes;
    IBOutlet NSTextField *exceptionsRemaningLabel;
    IBOutlet NSTableView *exceptionsTable;
    
    IBOutlet NSButton *closeWindowButton;
    IBOutlet NSButton *addExceptionButton;
    IBOutlet NSButton *removeExceptionButton;
    
    int maxExceptions;

    NSUserDefaults *defaults;
    
    NSMutableArray *exceptionsArray;
}

- (IBAction) openSettings: (id) sender;
- (IBAction) saved: (id) sender;
- (IBAction) defaultFocusMinutesUpdated: (id) sender;
- (IBAction) closeWindow: (id) sender;

- (void) awakeFromNib;
- (void) setDefaultSettingsIfFirstRun;

// Class methods to retrieve values for settings
+ (int) defaultFocusMintues;
+ (NSMutableArray*) exceptions;

// Table hooha
- (void) updateExceptionsRemaningLabelAndButtonAvailability;
- (IBAction) deleteSelectedException: (id) sender;
- (IBAction) createException: (id) sender;
- (int) numberOfRowsInTableView: (NSTableView*) aTableView;
- (id) tableView: (NSTableView*) aTableView 
       objectValueForTableColumn: (NSTableColumn*) aTableColumn
       row: (NSInteger) rowIndex;
- (void) tableView: (NSTableView*) aTableView
        setObjectValue: (id) anObject
        forTableColumn: (NSTableView*) aTableColumn
        row: (NSInteger) rowIndex;

@end
