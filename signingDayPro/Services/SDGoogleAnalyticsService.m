//
//  SDGoogleAnalyticsService.m
//  SigningDay
//
//  Created by Lukas Kekys on 11/25/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDGoogleAnalyticsService.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-45419104-1"; //Testing id
static NSString *const kAllowTracking = @"allowTracking";

@interface SDGoogleAnalyticsService ()

@property (nonatomic, strong) id<GAITracker> tracker;

@end

@implementation SDGoogleAnalyticsService

+ (id)sharedService
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action andLabel:(NSString *)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
    
}

- (void)trackUXEventWithLabel:(NSString *)label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:label
                                                           value:nil] build]];
}

- (void)trackAppViewWithName:(NSString *)name
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:name
                                                      forKey:kGAIScreenName] build]];
}

- (void)setupService
{
#warning will change after tests
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 60;
    
#ifdef DEBUG
    [GAI sharedInstance].dryRun = YES;
    [GAI sharedInstance].optOut = YES;
#else
    [GAI sharedInstance].dryRun = NO;
    [GAI sharedInstance].optOut = NO;
#endif
    //    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
}

@end
