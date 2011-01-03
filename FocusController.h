//
//  FocusController.h
//  focus
//
//  Created by Ben McRedmond on 25/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>
#import "SettingsController.h"

@interface FocusController : NSObject {
    IBOutlet NSWindow *focusWindow;
    IBOutlet NSTextField *focusMinutes;
    IBOutlet NSMenuItem *timeRemaning;
    IBOutlet NSMenuItem *startItem;
    
    NSInteger timeRemaningMinutes;
}

- (IBAction) openStartFocusingWindow: (id) sender;
- (IBAction) startFocusing: (id) sender;

@end
