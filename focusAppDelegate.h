//
//  focusAppDelegate.h
//  focus
//
//  Created by Ben McRedmond on 24/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface focusAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
