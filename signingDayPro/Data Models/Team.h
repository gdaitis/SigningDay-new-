//
//  Team.h
//  signingDayPro
//
//  Created by Lukas Kekys on 10/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coach, Member, Player, User;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSNumber * conferenceId;
@property (nonatomic, retain) NSString * conferenceLogoUrl;
@property (nonatomic, retain) NSString * conferenceLogoUrlBlack;
@property (nonatomic, retain) NSString * conferenceName;
@property (nonatomic, retain) NSString * conferenceRankingString;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * nationalRankingString;
@property (nonatomic, retain) NSNumber * numberOfCommits;
@property (nonatomic, retain) NSString * stateCode;
@property (nonatomic, retain) NSString * teamClass;
@property (nonatomic, retain) NSString * teamName;
@property (nonatomic, retain) NSNumber * totalScore;
@property (nonatomic, retain) NSString * universityName;
@property (nonatomic, retain) NSSet *favoritedBy;
@property (nonatomic, retain) Coach *headCoach;
@property (nonatomic, retain) User *theUser;
@property (nonatomic, retain) NSSet *commits;
@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addFavoritedByObject:(Member *)value;
- (void)removeFavoritedByObject:(Member *)value;
- (void)addFavoritedBy:(NSSet *)values;
- (void)removeFavoritedBy:(NSSet *)values;

- (void)addCommitsObject:(Player *)value;
- (void)removeCommitsObject:(Player *)value;
- (void)addCommits:(NSSet *)values;
- (void)removeCommits:(NSSet *)values;

@end
