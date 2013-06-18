//
//  User.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/18/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActivityStory, Comment, Conversation, Like, Master, Message;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfFollowers;
@property (nonatomic, retain) NSNumber * numberOfFollowing;
@property (nonatomic, retain) NSNumber * numberOfPhotos;
@property (nonatomic, retain) NSNumber * numberOfVideos;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *activityStories;
@property (nonatomic, retain) NSSet *authorOf;
@property (nonatomic, retain) NSSet *conversations;
@property (nonatomic, retain) Master *followedBy;
@property (nonatomic, retain) Master *following;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) Master *master;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *comments;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addActivityStoriesObject:(ActivityStory *)value;
- (void)removeActivityStoriesObject:(ActivityStory *)value;
- (void)addActivityStories:(NSSet *)values;
- (void)removeActivityStories:(NSSet *)values;

- (void)addAuthorOfObject:(Conversation *)value;
- (void)removeAuthorOfObject:(Conversation *)value;
- (void)addAuthorOf:(NSSet *)values;
- (void)removeAuthorOf:(NSSet *)values;

- (void)addConversationsObject:(Conversation *)value;
- (void)removeConversationsObject:(Conversation *)value;
- (void)addConversations:(NSSet *)values;
- (void)removeConversations:(NSSet *)values;

- (void)addLikesObject:(Like *)value;
- (void)removeLikesObject:(Like *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
