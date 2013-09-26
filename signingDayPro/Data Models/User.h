//
//  User.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActivityStory, Coach, Comment, Conversation, HighSchool, Like, Master, Member, Message, Notification, Player, State, Team;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * accountVerified;
@property (nonatomic, retain) NSNumber * allowBuzzMessage;
@property (nonatomic, retain) NSNumber * allowPrivateMessage;
@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSDate * followerRelationshipCreated;
@property (nonatomic, retain) NSDate * followingRelationshipCreated;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfFollowers;
@property (nonatomic, retain) NSNumber * numberOfFollowing;
@property (nonatomic, retain) NSNumber * numberOfPhotos;
@property (nonatomic, retain) NSNumber * numberOfVideos;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userType;
@property (nonatomic, retain) NSNumber * userTypeId;
@property (nonatomic, retain) NSSet *activityStories;
@property (nonatomic, retain) ActivityStory *activityStoriesFromOtherUsers;
@property (nonatomic, retain) NSSet *authorOf;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *conversations;
@property (nonatomic, retain) Master *followedBy;
@property (nonatomic, retain) Master *following;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) Master *master;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) State *state;
@property (nonatomic, retain) Coach *theCoach;
@property (nonatomic, retain) HighSchool *theHighSchool;
@property (nonatomic, retain) Member *theMember;
@property (nonatomic, retain) Player *thePlayer;
@property (nonatomic, retain) Team *theTeam;
@property (nonatomic, retain) NSSet *notificationsParticipatedIn;
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

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

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

- (void)addNotificationsParticipatedInObject:(Notification *)value;
- (void)removeNotificationsParticipatedInObject:(Notification *)value;
- (void)addNotificationsParticipatedIn:(NSSet *)values;
- (void)removeNotificationsParticipatedIn:(NSSet *)values;

@end
