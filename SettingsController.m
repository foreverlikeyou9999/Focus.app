//
//  SettingsController.m
//  focus
//
//  Created by Ben McRedmond on 24/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import "SettingsController.h"

@implementation SettingsController

- (id) init 
{
    self = [super init];
    
    defaults = [NSUserDefaults standardUserDefaults];
    [self setDefaultSettingsIfFirstRun];        

    exceptionsArray = (NSMutableArray*) [NSMutableArray arrayWithCapacity:5];
    
    // Not sure why but somewhere it's being released, quick fix for now
    [exceptionsArray retain];
    
    NSArray *exceptionsInPreferences = [defaults objectForKey:@"exceptions"];
    if(exceptionsInPreferences != nil) [exceptionsArray addObjectsFromArray:exceptionsInPreferences];

    maxExceptions = 5;
    
    return self;
}

- (void) dealloc 
{
    [exceptionsArray release];
    [super dealloc];
}

- (void) setDefaultSettingsIfFirstRun 
{
    BOOL openedBefore = [defaults boolForKey:@"openedBefore"];
    if(openedBefore == NO)
    {
        [defaults setBool:YES forKey:@"openedBefore"];
        [defaults setInteger: 60 forKey:@"defaultFocusMinutes"];        
        [defaults setObject:[NSMutableArray arrayWithObject:@"en.wikipedia.org"] forKey:@"exceptions"];        
        [defaults synchronize];
    }
}

+ (int) defaultFocusMintues
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultFocusMinutes"];
}

+ (NSMutableArray*) exceptions
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"exceptions"];
}

- (void) awakeFromNib 
{   
    [closeWindowButton setTransparent:YES];
    [defaultFocusMinutes setIntegerValue:[defaults integerForKey:@"defaultFocusMinutes"]];
    [self updateExceptionsRemaningLabelAndButtonAvailability];
}

- (IBAction) openSettings: (id) sender 
{
    // Since our app is an 'agent' it's never going to be the active application
    // so if we order the window to the front, it will appear at the front
    // but not really (the front of the focus application). So we need this so it
    // actually appears at the front.
    [NSApp activateIgnoringOtherApps:YES];
    [settingsWindow makeKeyAndOrderFront:self];
}

- (IBAction) saved: (id) sender 
{   
    [defaults setInteger:[defaultFocusMinutes integerValue] forKey:@"defaultFocusMinutes"];
    [defaults setObject:exceptionsArray forKey:@"exceptions"];    
    [defaults synchronize];
    [settingsWindow performClose:self];
}

- (IBAction) defaultFocusMinutesUpdated: (id) sender 
{
    [defaults setInteger: [sender integerValue] forKey:@"defaultFocusMinutes"];
    [defaults synchronize];
}

// There is a button in IB which is hidden in
// awakeFromNib:. It has the key equiv of cmd+w
- (IBAction) closeWindow: (id) sender 
{
    [self saved:self];
}

// Stuff which makes the table work
- (void) updateExceptionsRemaningLabelAndButtonAvailability 
{
    int remaningExceptions = ((maxExceptions) - [exceptionsArray count]);
    [exceptionsRemaningLabel setObjectValue:[NSString stringWithFormat:@"(%d remaning)", remaningExceptions]];
    
    if(remaningExceptions == maxExceptions)
    {
        [addExceptionButton setEnabled:YES];
        [removeExceptionButton setEnabled:NO];        
    } else if(remaningExceptions == 0)
    {
        [addExceptionButton setEnabled:NO];
        [removeExceptionButton setEnabled:YES];
    } else 
    {
        [addExceptionButton setEnabled:YES];
        [removeExceptionButton setEnabled:YES];
    }
}

- (IBAction) deleteSelectedException: (id) sender 
{
    NSInteger rowIndex = [exceptionsTable selectedRow];
    if(rowIndex == -1) 
    {
        NSBeep();
        return;
    } else {
        [exceptionsArray removeObjectAtIndex:rowIndex];
        NSLog(@"%d", [exceptionsArray count]);        
        [exceptionsTable reloadData];
        
        [self updateExceptionsRemaningLabelAndButtonAvailability];
    }
}

- (IBAction) createException: (id) sender 
{
    if([exceptionsArray count] >= maxExceptions)
    {
        NSBeep();
    } else {
        [exceptionsArray addObject:@""];
        [exceptionsTable reloadData];
        
        [self updateExceptionsRemaningLabelAndButtonAvailability];
    } 
}

- (int) numberOfRowsInTableView: (NSTableView*) aTableView 
{
    return [exceptionsArray count];
}

- (id) tableView: (NSTableView*) aTableView 
       objectValueForTableColumn: (NSTableColumn*) aTableColumn
       row: (NSInteger) rowIndex 
{
    return [exceptionsArray objectAtIndex:rowIndex];
}

- (void) tableView: (NSTableView *) aTableView
         setObjectValue: (id) anObject
         forTableColumn: (NSTableView*) aTableColumn
         row: (NSInteger) rowIndex
{
    [exceptionsArray insertObject: anObject atIndex:rowIndex];
    [exceptionsArray removeObjectAtIndex:(rowIndex + 1)];
}

@end