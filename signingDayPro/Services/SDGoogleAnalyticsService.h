//
//  SDGoogleAnalyticsService.h
//  SigningDay
//
//  Created by Lukas Kekys on 11/25/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDGoogleAnalyticsService : NSObject

+ (SDGoogleAnalyticsService *)sharedService;

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action andLabel:(NSString *)label;
- (void)trackUXEventWithLabel:(NSString *)label;
- (void)trackAppViewWithName:(NSString *)name;
- (void)setupService;

@end
