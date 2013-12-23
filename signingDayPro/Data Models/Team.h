//
//  Team.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coach, Member, Offer, TopSchool, User;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSNumber * conferenceId;
@property (nonatomic, retain) NSString * conferenceLogoUrl;
@property (nonatomic, retain) NSString * conferenceLogoUrlBlack;
@property (nonatomic, retain) NSString * conferenceName;
@property (nonatomic, retain) NSString * conferenceRankingString;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * locationExtended;
@property (nonatomic, retain) NSString * nationalRankingString;
@property (nonatomic, retain) NSNumber * numberOfCommits;
@property (nonatomic, retain) NSString * stateCode;
@property (nonatomic, retain) NSString * teamClass;
@property (nonatomic, retain) NSString * teamName;
@property (nonatomic, retain) NSNumber * totalScore;
@property (nonatomic, retain) NSString * universityName;
@property (nonatomic, retain) NSSet *favoritedBy;
@property (nonatomic, retain) NSSet *headCoaches;
@property (nonatomic, retain) NSSet *offers;
@property (nonatomic, retain) User *theUser;
@property (nonatomic, retain) NSSet *topSchools;
@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addFavoritedByObject:(Member *)value;
- (void)removeFavoritedByObject:(Member *)value;
- (void)addFavoritedBy:(NSSet *)values;
- (void)removeFavoritedBy:(NSSet *)values;

- (void)addHeadCoachesObject:(Coach *)value;
- (void)removeHeadCoachesObject:(Coach *)value;
- (void)addHeadCoaches:(NSSet *)values;
- (void)removeHeadCoaches:(NSSet *)values;

- (void)addOffersObject:(Offer *)value;
- (void)removeOffersObject:(Offer *)value;
- (void)addOffers:(NSSet *)values;
- (void)removeOffers:(NSSet *)values;

- (void)addTopSchoolsObject:(TopSchool *)value;
- (void)removeTopSchoolsObject:(TopSchool *)value;
- (void)addTopSchools:(NSSet *)values;
- (void)removeTopSchools:(NSSet *)values;

@end
