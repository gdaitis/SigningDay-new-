//
//  SDActivityFeedService.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedService.h"
#import "SDAPIClient.h"
#import "ActivityStory.h"
#import "User.h"
#import "Like.h"
#import "Comment.h"
#import "HTMLParser.h"
#import "SDUtils.h"

@interface SDActivityFeedService ()

+ (void)createCommentFromDictionary:(NSDictionary *)commentDictionary;
+ (void)createLikeFromDictionary:(NSDictionary *)likeDictionary;

@end



@implementation SDActivityFeedService

+ (void)getActivityStoriesForUser:(User *)user
                         withDate:(NSDate *)date
                 withSuccessBlock:(void (^)(int resultCount))successBlock
                     failureBlock:(void (^)(void))failureBlock
{
    NSMutableDictionary *params = nil;
    
    //if user provided, add parameter with user id to get only this users activity stories
    if (user) {
        params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[user.identifier stringValue], @"UserId", nil];
    }
    if (date) {
        NSString *formatedDateString = [SDUtils formatedDateStringFromDate:date];
        if (params == nil) {
            params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:formatedDateString, @"EndDate", nil];
        }
        else {
            [params setObject:formatedDateString forKey:@"EndDate"];
        }
    }
    
    [[SDAPIClient sharedClient] getPath:@"sd/story.json"
                             parameters:params
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    
                                    //no date provided that means we are downloading first page, old stories should be deleted
                                    if (!date) {
                                        [self markAllStoriesForDeletion];
                                    }
                                    
                                    int resultCount = [[JSON valueForKey:@"TotalCount"] intValue];
                                    
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSArray *activityStories = [JSON valueForKey:@"ActivityStories"];
                                    
                                    for (int i = 0; i < [activityStories count]; i++) {
                                        NSDictionary *activityStoryDictionary = [activityStories objectAtIndex:i];
                                        
                                        NSString *identifier = [activityStoryDictionary valueForKey:@"Id"];
                                        ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"identifier"
                                                                                                    withValue:identifier
                                                                                                    inContext:context];
                                        if (!activityStory) {
                                            activityStory = [ActivityStory MR_createInContext:context];
                                            activityStory.identifier = identifier;
                                        }
                                        
                                        activityStory.storyTypeId = [activityStoryDictionary valueForKey:@"StoryTypeId"];
                                        activityStory.contentId = [activityStoryDictionary valueForKey:@"ContentId"];
                                        activityStory.contentTypeId = [activityStoryDictionary valueForKey:@"ContentTypeId"];
                                        activityStory.likesCount = [NSNumber numberWithInt:[[activityStoryDictionary valueForKey:@"LikesCount"] intValue]];
                                        activityStory.commentCount = [NSNumber numberWithInt:[[activityStoryDictionary valueForKey:@"CommentsCount"] intValue]];
                                        activityStory.likedByMaster = [NSNumber numberWithBool:[[activityStoryDictionary valueForKey:@"LikeFlag"] boolValue]];
                                        activityStory.shouldBeDeleted = [NSNumber numberWithBool:NO];
                                        
                                        if ([activityStoryDictionary valueForKey:@"DescriptionText"] != [NSNull null]) {
                                            activityStory.activityDescription = [activityStoryDictionary valueForKey:@"DescriptionText"];
                                        }
                                        if ([activityStoryDictionary valueForKey:@"MessageText"] != [NSNull null]) {
                                            activityStory.activityTitle = [activityStoryDictionary valueForKey:@"MessageText"];
                                        }
                                        
                                        NSString *createdDateString = [activityStoryDictionary objectForKey:@"CreatedDate"];
                                        NSString *lastUpdateDateString = [activityStoryDictionary objectForKey:@"LastUpdatedDate"];
                                        activityStory.createdDate = [SDUtils dateFromString:createdDateString];
                                        activityStory.lastUpdateDate = [SDUtils dateFromString:lastUpdateDateString];

                                        if ([activityStoryDictionary valueForKey:@"MediaType"] != [NSNull null]) {
                                            activityStory.mediaType = [activityStoryDictionary valueForKey:@"MediaType"];
                                        }
                                        if ([activityStoryDictionary valueForKey:@"ThumbnailUrl"] != [NSNull null]) {
                                            activityStory.thumbnailUrl = [activityStoryDictionary valueForKey:@"ThumbnailUrl"];
                                        }
                                        if ([activityStoryDictionary valueForKey:@"MediaUrl"] != [NSNull null]) {
                                            activityStory.contentTypeId = [activityStoryDictionary valueForKey:@"MediaUrl"];
                                        }
                                        
                                        //parse users(actors/authors) in this activity story
                                        NSArray *userArray = [activityStoryDictionary valueForKey:@"Users"];
                                        for (NSDictionary *userDictionary in userArray) {
                                            
                                            //cycle through array and creates updates users
                                            [self createUpdateUserFromDictionary:userDictionary withActivityStory:activityStory inContext:context];
                                        }
                                    }
                                    [context MR_saveToPersistentStoreAndWait];
                                    
                                    //returns only after deleting
                                    [self deleteAllMarkedStories];
                                    if (successBlock) {
                                        successBlock(resultCount);
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    failureBlock();
                                }];
    
}

+ (void)createUpdateUserFromDictionary:(NSDictionary *)dictionary withActivityStory:(ActivityStory *)activityStory inContext:(NSManagedObjectContext *)context
{
    NSNumber *authorIdentifier = [NSNumber numberWithInt:[[dictionary valueForKey:@"Id"] intValue]];
    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:authorIdentifier inContext:context];
    if (!user) {
        user = [User MR_createInContext:context];
        user.identifier = authorIdentifier;
    }
    user.username = [dictionary valueForKey:@"Username"];
    user.avatarUrl = [dictionary valueForKey:@"AvatarUrl"];
    user.name = [dictionary valueForKey:@"DisplayName"];
    
    if ([[dictionary valueForKey:@"Verb"] isEqualToString:@"From"]) {
        //this user created this post, assign it as author
        activityStory.author = user;
    }
    if ([[dictionary valueForKey:@"Verb"] isEqualToString:@"For"]) {
        //this is a wall post, activityStory posted on this users wall
        activityStory.postedToUser = user;
    }
    
    
    
    //check user type and save info depending on this type
    int userTypeId = [[dictionary valueForKey:@"UserTypeId"] intValue];
    
    if (userTypeId == 1) {
        //user type: Player
        user.userType = @"Player";
        NSDictionary *attributeDictionary = [dictionary objectForKey:@"Attributes"];
        
        if (attributeDictionary) {
            if ([attributeDictionary valueForKey:@"Position"] != [NSNull null]) {
                user.position = [attributeDictionary valueForKey:@"Position"];
            }
            if ([attributeDictionary valueForKey:@"Class"] != [NSNull null]) {
                user.userClass = [[attributeDictionary valueForKey:@"Class"] stringValue];
            }
        }
    }
    else if (userTypeId == 2) {
        //user type: TEAM
        user.userType = @"Team";
        NSDictionary *attributeDictionary = [dictionary objectForKey:@"Attributes"];
        
        if (attributeDictionary) {
            if ([attributeDictionary valueForKey:@"CityName"] != [NSNull null]) {
                user.position = [attributeDictionary valueForKey:@"CityName"];
            }
            if ([attributeDictionary valueForKey:@"StateCode"] != [NSNull null]) {
                user.userClass = [NSString stringWithFormat:@"%d",[[attributeDictionary valueForKey:@"StateCode"] intValue]];
            }
        }
    }
    else if (userTypeId == 3) {
        //user type: Coach
        user.userType = @"Coach";
        NSDictionary *attributeDictionary = [dictionary objectForKey:@"Attributes"];
        
        if (attributeDictionary) {
            if ([attributeDictionary valueForKey:@"Institution"] != [NSNull null]) {
                user.institution = [attributeDictionary valueForKey:@"Institution"];
            }
        }
    }
    else if (userTypeId == 4) {
 
        //user type: HighSchool
        user.userType = @"HighSchool";
        NSDictionary *attributeDictionary = [dictionary objectForKey:@"Attributes"];
        
        if (attributeDictionary) {
            if ([attributeDictionary valueForKey:@"CityName"] != [NSNull null]) {
                user.position = [attributeDictionary valueForKey:@"CityName"];
            }
            if ([attributeDictionary valueForKey:@"StateCode"] != [NSNull null]) {
                user.userClass = [NSString stringWithFormat:@"%d",[[attributeDictionary valueForKey:@"StateCode"] intValue]];
            }
        }
    }
    else {
        //user type: Member
        user.userType = @"HighSchool";
        
        //member doesn't have attributes so nothing to do here
    }
}

+ (void)postActivityStoryWithMessageBody:(NSString *)messageBody
                            successBlock:(void (^)(void))successBlock
                            failureBlock:(void (^)(void))failureBlock
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    
    NSString *path = [NSString stringWithFormat:@"users/%@/statuses.json", username];
    [[SDAPIClient sharedClient] postPath:path
                              parameters:@{@"Username": username, @"MessageBody":messageBody}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     failureBlock();
                                 }];
}

+ (void)likeActivityStory:(ActivityStory *)activityStory
             successBlock:(void (^)(void))successBlock
             failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"likes.json"
                              parameters:@{@"ContentId":activityStory.contentId, @"ContentTypeId":activityStory.contentTypeId}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSDictionary *likeDictionary = [JSON valueForKey:@"Like"];
                                     [self createLikeFromDictionary:likeDictionary];
                                     successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     failureBlock();
                                 }];
}

+ (void)unlikeActivityStory:(ActivityStory *)activityStory
               successBlock:(void (^)(void))successBlock
               failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] deletePath:@"like.json"
                                parameters:@{@"ContentId":activityStory.contentId}
                                   success:^(AFHTTPRequestOperation *operation, id JSON) {
                                       
                                       NSManagedObjectContext *deletionContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                       [activityStory MR_deleteEntity];
                                       [deletionContext MR_saveToPersistentStoreAndWait];
                                       if (successBlock) {
                                           successBlock();
                                       }
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failureBlock();
                                   }];
}

+ (void)addCommentToActivityStory:(ActivityStory *)activityStory
                             text:(NSString *)commentText
                     successBlock:(void (^)(void))successBlock
                     failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"comments.json"
                              parameters:@{@"ContentId":activityStory.contentId, @"ContentTypeId":activityStory.contentTypeId, @"Body":commentText}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSDictionary *commentDictionary = [JSON valueForKey:@"Comment"];
                                     [self createCommentFromDictionary:commentDictionary];
                                     successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     failureBlock();
                                 }];
}

+ (void)removeComment:(Comment *)comment
         successBlock:(void (^)(void))successBlock
         failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"comments/%@", comment.commentId];
    [[SDAPIClient sharedClient] deletePath:path
                                parameters:@{@"CommentId":comment.commentId}
                                   success:^(AFHTTPRequestOperation *operation, id JSON) {
                                       NSManagedObjectContext *deletionContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                       [comment MR_deleteEntity];
                                       [deletionContext MR_saveToPersistentStoreAndWait];
                                       if (successBlock) {
                                           successBlock();
                                       }
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       failureBlock();
                                   }];
}

#pragma mark - Private methods

+ (void)createCommentFromDictionary:(NSDictionary *)commentDictionary
{
    NSString *commentId = [commentDictionary valueForKey:@"CommentId"];
    NSString *contentId = [[commentDictionary valueForKey:@"Content"] valueForKey:@"ContentId"];
    NSManagedObjectContext *commentsContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Comment *comment = [Comment MR_findFirstByAttribute:@"commentId"
                                              withValue:commentId
                                              inContext:commentsContext];
    if (!comment) {
        comment = [Comment MR_createInContext:commentsContext];
        
        comment.commentId = commentId;
        
        NSString *createdDateString = [[commentDictionary objectForKey:@"CreatedDate"] stringByDeletingPathExtension];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *createdDate = [dateFormatter dateFromString:createdDateString];
        comment.createdDate = createdDate;
        
        ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"contentId"
                                                                    withValue:contentId
                                                                    inContext:commentsContext];
        comment.activityStory = activityStory;
    }
    
    NSString *commentBody = [commentDictionary valueForKey:@"Body"];
    comment.body = commentBody;
    
    NSDictionary *userDictionary = [commentDictionary valueForKey:@"User"];
    NSNumber *identifier = [NSNumber numberWithInt:[[userDictionary valueForKey:@"Id"] intValue]];
    User *user = [User MR_findFirstByAttribute:@"identifier"
                                     withValue:identifier
                                     inContext:commentsContext];
    if (!user) {
        user = [User MR_createInContext:commentsContext];
        user.identifier = identifier;
    }
    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
    user.username = [userDictionary valueForKey:@"Username"];
    user.name = [userDictionary valueForKey:@"DisplayName"];
    comment.user = user;
    
    NSString *updatedDateString = [[commentDictionary objectForKey:@"UpdatedDate"] stringByDeletingPathExtension];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSDate *updatedDate = [dateFormatter dateFromString:updatedDateString];
    comment.updatedDate = updatedDate;
    
    [commentsContext MR_saveToPersistentStoreAndWait];
}

+ (void)createLikeFromDictionary:(NSDictionary *)likeDictionary
{
    NSManagedObjectContext *likesContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSString *contentId = [[likeDictionary valueForKey:@"Content"] valueForKey:@"ContentId"];
    NSPredicate *activityStoryPredicate = [NSPredicate predicateWithFormat:@"activityStory.contentId == %@", contentId];
    
    NSNumber *identifier = [NSNumber numberWithInt:[[[likeDictionary valueForKey:@"User"] valueForKey:@"Id"] intValue]];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user.identifier == %@", identifier];
    
    NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[activityStoryPredicate, userPredicate]];
    Like *like = [Like MR_findFirstWithPredicate:andPredicate
                                       inContext:likesContext];
    if (!like) {
        like = [Like MR_createInContext:likesContext];
        
        ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"contentId"
                                                                    withValue:contentId
                                                                    inContext:likesContext];
        like.activityStory = activityStory;
        
        NSString *createdDateString = [[likeDictionary objectForKey:@"CreatedDate"] stringByDeletingPathExtension];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSDate *createdDate = [dateFormatter dateFromString:createdDateString];
        like.createdDate = createdDate;
    }
    NSDictionary *userDictionary = [likeDictionary valueForKey:@"User"];
    User *user = [User MR_findFirstByAttribute:@"identifier"
                                     withValue:identifier
                                     inContext:likesContext];
    if (!user) {
        user = [User MR_createInContext:likesContext];
        user.identifier = identifier;
    }
    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
    user.username = [userDictionary valueForKey:@"Username"];
    user.name = [userDictionary valueForKey:@"DisplayName"];
    like.user = user;
    [likesContext MR_saveToPersistentStoreAndWait];
}


+ (void)deleteAllActivityStories
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *activityStoryArray = [ActivityStory MR_findAllInContext:context];
    
    for (ActivityStory *story in activityStoryArray) {
        [context deleteObject:story];
    }
    [context MR_saveToPersistentStoreAndWait];
}

+ (void)markAllStoriesForDeletion
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *allStories = [ActivityStory MR_findAllInContext:context];
    
    for (ActivityStory *story in allStories) {
        story.shouldBeDeleted = [NSNumber numberWithBool:YES];
    }
    [context MR_saveToPersistentStoreAndWait];
}

+ (void)deleteAllMarkedStories
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *allStories = [ActivityStory MR_findAllInContext:context];
    
    for (ActivityStory *story in allStories) {
        if ([story.shouldBeDeleted boolValue]) {
            [context deleteObject:story];
        }
    }
    [context MR_saveToPersistentStoreAndWait];
}

@end