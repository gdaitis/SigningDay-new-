//
//  Member.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Team, User;

@interface Member : NSManagedObject

@property (nonatomic, retain) NSDate * memberSince;
@property (nonatomic, retain) NSNumber * postsCount;
@property (nonatomic, retain) NSNumber * uploadsCount;
@property (nonatomic, retain) Team *favoriteTeam;
@property (nonatomic, retain) User *theUser;

@end
