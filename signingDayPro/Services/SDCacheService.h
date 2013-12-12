//
//  SDCacheService.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDCacheService : NSObject

+ (BOOL)shouldTeamsBeUpdated;
+ (void)teamsShouldBeUpdateWhenNeeded;
+ (void)teamsUpdated;

@end
