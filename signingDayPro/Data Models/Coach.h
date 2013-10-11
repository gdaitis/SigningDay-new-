//
//  Coach.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 10/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coach, Team, User;

@interface Coach : NSManagedObject

@property (nonatomic, retain) NSString * institution;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * coachLevel;
@property (nonatomic, retain) Team *team;
@property (nonatomic, retain) User *theUser;
@property (nonatomic, retain) NSSet *subCoaches;
@property (nonatomic, retain) Coach *superCoach;
@end

@interface Coach (CoreDataGeneratedAccessors)

- (void)addSubCoachesObject:(Coach *)value;
- (void)removeSubCoachesObject:(Coach *)value;
- (void)addSubCoaches:(NSSet *)values;
- (void)removeSubCoaches:(NSSet *)values;

@end
