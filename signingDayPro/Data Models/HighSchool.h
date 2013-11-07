//
//  HighSchool.h
//  SigningDay
//
//  Created by Lukas Kekys on 11/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player, User;

@interface HighSchool : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * baseAverage;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * headCoachName;
@property (nonatomic, retain) NSString * mascot;
@property (nonatomic, retain) NSString * stateCode;
@property (nonatomic, retain) NSNumber * totalProspects;
@property (nonatomic, retain) NSSet *players;
@property (nonatomic, retain) NSSet *rosters;
@property (nonatomic, retain) User *theUser;
@end

@interface HighSchool (CoreDataGeneratedAccessors)

- (void)addPlayersObject:(Player *)value;
- (void)removePlayersObject:(Player *)value;
- (void)addPlayers:(NSSet *)values;
- (void)removePlayers:(NSSet *)values;

- (void)addRostersObject:(Player *)value;
- (void)removeRostersObject:(Player *)value;
- (void)addRosters:(NSSet *)values;
- (void)removeRosters:(NSSet *)values;

@end
