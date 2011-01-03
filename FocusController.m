//
//  FocusController.m
//  focus
//
//  Created by Ben McRedmond on 25/12/2010.
//  Copyright 2010 Ben McRedmond. All rights reserved.
//

#import "FocusController.h"


@implementation FocusController

- (id) init
{
    self = [super init];
    
    return self;    
}

- (void) awakeFromNib
{
    [focusMinutes setIntegerValue:[SettingsController defaultFocusMintues]];
}

- (IBAction) openStartFocusingWindow: (id) sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [focusWindow makeKeyAndOrderFront:self];
    return;
}

- (NSString*) OSStatusToNSString: (OSStatus) status
{
    return [NSString stringWithCString:GetMacOSStatusErrorString(status) encoding:[NSString defaultCStringEncoding]];
}

- (AuthorizationRef) setupAuthorization
{
	AuthorizationRef authorizationRef;
	OSStatus status;
	
	status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
	if(status != errAuthorizationSuccess) NSLog(@"Authorization Create Error: %@", [self OSStatusToNSString:status]);
	
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagDefaults |
                               kAuthorizationFlagInteractionAllowed |
                               kAuthorizationFlagPreAuthorize |
                               kAuthorizationFlagExtendRights;

    status = AuthorizationCopyRights(authorizationRef, &rights, NULL, flags, NULL);
    if(status != errAuthorizationSuccess) NSLog(@"Authorization Rights Copy Error: %@", [self OSStatusToNSString:status]);
    
    return authorizationRef;
}

- (IBAction) startFocusing: (id) sender
{    
    AuthorizationRef authorizationRef = [self setupAuthorization];
    OSStatus status; 
    
    NSString *pathToHelper = [NSString stringWithFormat:@"%@/FocusHelper", [[NSBundle mainBundle] resourcePath]];
    
	// We have to use an external tool otherwise when we want to
    // reenable the network connectivity unless delay is < 5 minutes
    // the user would have to enter a password and that sucks
	char *tool = [pathToHelper cStringUsingEncoding:[NSString defaultCStringEncoding]];
	char *args[] = {[[focusMinutes stringValue] cStringUsingEncoding:[NSString defaultCStringEncoding]], NULL};
		
    status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, args, NULL);
    if(status != errAuthorizationSuccess) NSLog(@"Error Executing With Authorization: %@", [self OSStatusToNSString:status]);
}

@end