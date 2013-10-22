//
//  Forum.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Thread;

@interface Forum : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * forumDescription;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * latestPostDate;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * replyCount;
@property (nonatomic, retain) NSNumber * threadCount;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSSet *threads;
@end

@interface Forum (CoreDataGeneratedAccessors)

- (void)addThreadsObject:(Thread *)value;
- (void)removeThreadsObject:(Thread *)value;
- (void)addThreads:(NSSet *)values;
- (void)removeThreads:(NSSet *)values;

@end
