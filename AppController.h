//
//  AppController.h
//  focus
//
//  Created by Ben McRedmond on 24/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "SettingsController.h"

@interface AppController : NSObject {
	// Lets us put 'menu' in MenuBar
	NSStatusItem *statusItem;
	
	// The main menu
	IBOutlet NSMenu *menu;
	IBOutlet NSMenuItem *countdown;
	IBOutlet NSMenuItem *start;
	IBOutlet NSMenuItem *settings;
}

@end
