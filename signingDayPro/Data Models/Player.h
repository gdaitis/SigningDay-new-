//
//  Player.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HighSchool, Offer, TopSchool, User;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSNumber * baseScore;
@property (nonatomic, retain) NSNumber * has150Badge;
@property (nonatomic, retain) NSNumber * hasWatchListBadge;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * nationalRanking;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * positionRanking;
@property (nonatomic, retain) NSNumber * starsCount;
@property (nonatomic, retain) NSNumber * stateRanking;
@property (nonatomic, retain) NSString * userClass;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) HighSchool *highSchool;
@property (nonatomic, retain) NSSet *offers;
@property (nonatomic, retain) HighSchool *rosterOf;
@property (nonatomic, retain) User *theUser;
@property (nonatomic, retain) NSSet *topSchools;
@end

@interface Player (CoreDataGeneratedAccessors)

- (void)addOffersObject:(Offer *)value;
- (void)removeOffersObject:(Offer *)value;
- (void)addOffers:(NSSet *)values;
- (void)removeOffers:(NSSet *)values;

- (void)addTopSchoolsObject:(TopSchool *)value;
- (void)removeTopSchoolsObject:(TopSchool *)value;
- (void)addTopSchools:(NSSet *)values;
- (void)removeTopSchools:(NSSet *)values;

@end
