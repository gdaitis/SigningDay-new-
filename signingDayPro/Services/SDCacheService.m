//
//  SDCacheService.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCacheService.h"

#define kLastTeamUpdateDate @"LastTeamUpdateDate"
#define kUpdateIntervalInSeconds 3600  //1 hour

@implementation SDCacheService

+ (BOOL)shouldTeamsBeUpdated
{
    
    BOOL result = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:kLastTeamUpdateDate]) {
        result = YES;
    }
    else {
        
        NSDate *currentDate = [NSDate date];
        NSDate *lastUpdateDate = [defaults valueForKey:kLastTeamUpdateDate];
        NSTimeInterval secondsBetween = [currentDate timeIntervalSinceDate:lastUpdateDate];
        if (ABS(secondsBetween) > kUpdateIntervalInSeconds) {
            result = YES;
        }
    }
    
    return result;
}

+ (void)teamsShouldBeUpdateWhenNeeded
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastTeamUpdateDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)teamsUpdated
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastTeamUpdateDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
