//
//  Group.h
//  SigningDay
//
//  Created by Lukas Kekys on 11/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Forum;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * groupDescription;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * isEnabled;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSSet *forums;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addForumsObject:(Forum *)value;
- (void)removeForumsObject:(Forum *)value;
- (void)addForums:(NSSet *)values;
- (void)removeForums:(NSSet *)values;

@end
