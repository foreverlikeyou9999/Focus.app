//
//  SettingsController.m
//  focus
//
//  Created by Ben McRedmond on 24/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import "SettingsController.h"

@implementation SettingsController

@synthesize exceptions;

- (id) init 
{
    self = [super init];
    
    validate = [[BMValidation alloc] init];
    [validate setDelegate:self];
    
    defaults = [NSUserDefaults standardUserDefaults];
    exceptions = [defaults objectForKey:@"exceptions"];

    maxExceptions = 5;
    
    return self;
}

- (void) dealloc 
{
    [validate release];
    [exceptions release];
    [super dealloc];
}

+ (void) setDefaultSettingsIfFirstRun 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
    [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultFocusMinutes"];
}

+ (NSMutableArray*) exceptions
{
    [[NSUserDefaults standardUserDefaults] objectForKey:@"exceptions"];
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
    [defaults setObject:exceptions forKey:@"exceptions"];    
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
    int remaningExceptions = ((maxExceptions) - [exceptions count]);
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
        [exceptions removeObjectAtIndex:rowIndex];
        NSLog(@"%d", [exceptions count]);        
        [exceptionsTable reloadData];
        
        [self updateExceptionsRemaningLabelAndButtonAvailability];
    }
}

- (IBAction) createException: (id) sender 
{
    if([exceptions count] >= maxExceptions)
    {
        NSBeep();
    } else {
        [exceptions addObject:@""];
        [exceptionsTable reloadData];
        
        [self updateExceptionsRemaningLabelAndButtonAvailability];
    } 
}

- (int) numberOfRowsInTableView: (NSTableView*) aTableView 
{
    return [exceptions count];
}

- (id) tableView: (NSTableView*) aTableView 
       objectValueForTableColumn: (NSTableColumn*) aTableColumn
       row: (NSInteger) rowIndex 
{
    return [exceptions objectAtIndex:rowIndex];
}

- (void) tableView: (NSTableView *) aTableView
         setObjectValue: (id) anObject
         forTableColumn: (NSTableView*) aTableColumn
         row: (NSInteger) rowIndex
{
    [exceptions insertObject: anObject atIndex:rowIndex];
    [exceptions removeObjectAtIndex:(rowIndex + 1)];
}

@end