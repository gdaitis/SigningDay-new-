//
//  Thread.h
//  SigningDay
//
//  Created by Lukas Kekys on 11/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Forum, ForumReply, User;

@interface Thread : NSManagedObject

@property (nonatomic, retain) NSString * bodyText;
@property (nonatomic, retain) NSNumber * countOfBelieves;
@property (nonatomic, retain) NSNumber * countOfHates;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * latestPostDate;
@property (nonatomic, retain) NSNumber * replyCount;
@property (nonatomic, retain) NSNumber * shouldBeDeleted;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) User *authorUser;
@property (nonatomic, retain) Forum *forum;
@property (nonatomic, retain) NSSet *forumReplies;
@end

@interface Thread (CoreDataGeneratedAccessors)

- (void)addForumRepliesObject:(ForumReply *)value;
- (void)removeForumRepliesObject:(ForumReply *)value;
- (void)addForumReplies:(NSSet *)values;
- (void)removeForumReplies:(NSSet *)values;

@end
