//
//  Player.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 10/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HighSchool, User;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSNumber * baseScore;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * nationalRanking;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * positionRanking;
@property (nonatomic, retain) NSNumber * starsCount;
@property (nonatomic, retain) NSNumber * stateRanking;
@property (nonatomic, retain) NSString * userClass;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) HighSchool *highSchool;
@property (nonatomic, retain) User *theUser;

@end
