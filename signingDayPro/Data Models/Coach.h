//
//  Coach.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coach, Team, User;

@interface Coach : NSManagedObject

@property (nonatomic, retain) NSNumber * coachLevel;
@property (nonatomic, retain) NSString * institution;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSSet *subCoaches;
@property (nonatomic, retain) Coach *superCoach;
@property (nonatomic, retain) Team *team;
@property (nonatomic, retain) User *theUser;
@end

@interface Coach (CoreDataGeneratedAccessors)

- (void)addSubCoachesObject:(Coach *)value;
- (void)removeSubCoachesObject:(Coach *)value;
- (void)addSubCoaches:(NSSet *)values;
- (void)removeSubCoaches:(NSSet *)values;

@end
