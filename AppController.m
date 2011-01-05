//
//  AppController.m
//  focus
//
//  Created by Ben McRedmond on 24/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (void) awakeFromNib 
{
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [[statusBar statusItemWithLength:NSVariableStatusItemLength] retain];
    
    [statusItem setHighlightMode:YES];
    [statusItem setImage:[NSImage imageNamed:@"icon.png"]];
    [statusItem setEnabled:YES];    
	[statusItem setMenu:menu];
}

@end
