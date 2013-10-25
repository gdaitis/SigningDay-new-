//
//  State.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface State : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * isInUS;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *user;
@end

@interface State (CoreDataGeneratedAccessors)

- (void)addUserObject:(User *)value;
- (void)removeUserObject:(User *)value;
- (void)addUser:(NSSet *)values;
- (void)removeUser:(NSSet *)values;

@end
