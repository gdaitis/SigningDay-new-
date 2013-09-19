//
//  NSObject+MasterUserMethods.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/18/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "NSObject+MasterUserMethods.h"
#import "Master.h"
#import "User.h"

@implementation NSObject (MasterUserMethods)

- (NSNumber *)getMasterIdentifier
{
    Master *master = [self getMaster];
    return master.identifier;
}

- (Master *)getMaster
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    return master;
}

- (User *)getMasterUser
{
    User *masterUser = [User MR_findFirstByAttribute:@"identifier" withValue:[self getMasterIdentifier] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return masterUser;
}

+ (NSNumber *)getMasterIdentifier
{
    Master *master = [self getMaster];
    return master.identifier;
}

+ (Master *)getMaster
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    return master;
}

+ (User *)getMasterUser
{
    User *masterUser = [User MR_findFirstByAttribute:@"identifier" withValue:[self getMasterIdentifier] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return masterUser;
}

@end
