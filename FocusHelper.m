//
//  FocusHelper.m
//  focus
//
//  Created by Ben McRedmond on 03/01/2011.
//  Copyright 2011 Ben McRedmond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSTask* runIPFWCommand(NSString* command)
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/sbin/ipfw"];
    [task setArguments:[NSArray arrayWithObject:command]];
    [task setStandardOutput:[NSPipe pipe]];
    
    // Thundercats Goooooooo!
    [task launch];
    return task;
}

void removeRulesWithIDs(NSArray* ruleIDs)
{
    for(id ruleID in ruleIDs)
    {
        NSString *command = [NSString stringWithFormat:@"delete %@", ruleID];
        [runIPFWCommand(command) release];
    }
}

void removeCurrentRules()
{
    NSArray *currentRuleIDs = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentRuleIDs"];
    removeRulesWithIDs(currentRuleIDs);
    NSLog(@"Removed internet block");
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"currentRuleIDs"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"focusing"];
}

NSString* ruleIDFromNSTaskAndRelease(NSTask* task)
{
    NSFileHandle *fileHandle = [[task standardOutput] fileHandleForReading];
    NSString *string = [[NSString alloc] initWithData:[fileHandle readDataOfLength:5] encoding:NSASCIIStringEncoding];
    
    [task release];
    return string;
}

NSString* blockAllOutgoing()
{
    return ruleIDFromNSTaskAndRelease(runIPFWCommand(@"add deny out"));
}

NSMutableArray* allowAllOutgoingDNS()
{
    NSArray *DNSIPFWRules = [NSArray arrayWithObjects:@"add allow tcp from any to any 53 setup", @"add allow udp from any to any 53", @"add allow udp from any 53 to any", nil];
    NSMutableArray *DNSExceptionRuleIDs = [NSMutableArray arrayWithCapacity:[DNSIPFWRules count]];

    for(id rule in DNSIPFWRules)
    {
       [DNSExceptionRuleIDs addObject:ruleIDFromNSTaskAndRelease(runIPFWCommand(rule))];
    }

    return DNSExceptionRuleIDs;
}

NSMutableArray* allowAllOutgoingExceptions(NSArray *exceptions)
{
    NSMutableArray *exceptionRuleIDs = [NSMutableArray arrayWithCapacity:[exceptions count]];
    NSArray *protocols = [NSArray arrayWithObjects:@"tcp", @"udp", @"icmp", nil];
    NSLog(@"Adding allowances for exceptions, this might take a few seconds while domain names are resolved");
    
    int i = 1;
    for(id exception in exceptions) 
    {
        // No sneaky exceptions! Some self glorified hacker might decide
        // just wikipedia isn't good enough and he needs some Paul Graham
        // glorified productivity tips from Hacker News by modifying
        // the plist, ye well, not so smart now. Ass. Except if they were
        // infact a glorified hacker rather than self glorified they could
        // quite simply just modify ipfw from the command line, ye. :(
        // So really, this line is completely pointless other than for a reason
        // to have this quite wonderful comment because lets be honest if
        // you're sad enough to  have to be reading code about allowing outgoing exceptions
        // with authorization references, this certainly brightend (that's how you
        // spell that I think) your day, one can only hope. Otherwise I really have
        // wasted 11 lines. It's a possibility since I really am not that funny
        // oh look now it's 12 lines. Anyways, good day, good friend.
        if(i > 5) break;
    	        
        for(id protocol in protocols)
        {
            NSString *command = [NSString stringWithFormat:@"add allow %@ from any to %@", protocol, exception];
            [exceptionRuleIDs addObject:ruleIDFromNSTaskAndRelease(runIPFWCommand(command))];   
        }        
        
        i++;
    }
    
    return exceptionRuleIDs;
}

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *newRuleIDs = [NSMutableArray arrayWithCapacity:9];
        
    [newRuleIDs addObjectsFromArray:allowAllOutgoingDNS()];    
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.benmcredmond.focus"];    
    [newRuleIDs addObjectsFromArray:allowAllOutgoingExceptions([prefs objectForKey:@"exceptions"])];
        
    [newRuleIDs addObject:blockAllOutgoing()];
    
    [[NSUserDefaults standardUserDefaults] setObject:newRuleIDs forKey:@"currentRuleIDs"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"focusing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    int sleepTime = atoi(argv[1]) * 60;
    NSLog(@"Helper sleeping for: %d seconds", sleepTime);
    sleep(sleepTime);
    
    removeCurrentRules();
    
    [pool drain];
}