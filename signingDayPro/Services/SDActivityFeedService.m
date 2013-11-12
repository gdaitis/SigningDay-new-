//
//  SDActivityFeedService.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedService.h"
#import "SDAPIClient.h"
#import "AFNetworking.h"
#import "WebPreview.h"
#import "ActivityStory.h"
#import "User.h"
#import "Player.h"
#import "Team.h"
#import "Coach.h"
#import "HighSchool.h"
#import "Member.h"
#import "Like.h"
#import "Master.h"
#import "Comment.h"
#import "HTMLParser.h"
#import "SDUtils.h"
#import "SDErrorService.h"
#import "NSString+HTML.h"
#import "SDProfileService.h"
#import "NSDictionary+NullConverver.h"

@implementation SDActivityFeedService

+ (void)getActivityStoriesForUser:(User *)user
                         withDate:(NSDate *)date
                     andDeleteOld:(BOOL)deleteOld
                 withSuccessBlock:(void (^)(NSDictionary *results))successBlock
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
                                    
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    //check for old stories to be deleted. Usually on pull to refresh
                                    if (deleteOld) {
                                        [self markAllStoriesForDeletionInContext:context];
                                    }
                                    int resultCount = 0;
                                    int dataCount = [[JSON valueForKey:@"TotalCount"] intValue];
                                    NSArray *activityStories = [JSON valueForKey:@"ActivityStories"];
                                    BOOL endReached = YES;
                                    NSDate *lastDate = nil;
                                    
                                    if (dataCount > 0) {
                                        
                                        for (int i = 0; i < [activityStories count]; i++) {
                                            endReached = NO;
                                            NSDictionary *activityStoryDictionary = [[activityStories objectAtIndex:i] dictionaryByReplacingNullsWithStrings];
                                            
                                            BOOL activityStoryValid = [self validateActivityStory:activityStoryDictionary fromContext:context];
                                            /*activity story is not forum activity and nflpa not involved */
                                            
                                            if (activityStoryValid) {
                                                [self createActivityStoryFromDictionary:activityStoryDictionary
                                                                                context:context];
                                                resultCount++;
                                            }
                                            if (i+1 == dataCount) {
                                                NSString *lastUpdateDateString = [activityStoryDictionary objectForKey:@"LastUpdatedDate"];
                                                lastDate = [SDUtils notLocalizedDateFromString:lastUpdateDateString];
                                            }
                                        }
                                    }
                                    
                                    NSMutableDictionary *resultsDictionary = [[NSMutableDictionary alloc] init];
                                    [resultsDictionary setObject:[NSNumber numberWithInt:resultCount] forKey:@"ResultCount"];
                                    [resultsDictionary setObject:[NSNumber numberWithBool:endReached] forKey:@"EndReached"];
                                    if (lastDate) {
                                        [resultsDictionary setObject:lastDate forKey:@"LastDate"];
                                    }
                                    NSLog(@"result count = %d",resultCount);
                                    
                                    [context MR_saveOnlySelfAndWait];
                                    
                                    //returns only after deleting
                                    if (deleteOld) {
                                        [self deleteAllMarkedStoriesInContext:context];
                                    }
                                    if (successBlock) {
                                        successBlock(resultsDictionary);
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (BOOL)validateActivityStory:(NSDictionary *)activityStoryDictionary fromContext:(NSManagedObjectContext *)context
{
    BOOL valid = YES;
    if ([[activityStoryDictionary valueForKey:@"MediaType"] length] == 0 && [[activityStoryDictionary valueForKey:@"MediaUrl"] length] == 0 ) {
        if ([[activityStoryDictionary valueForKey:@"MessageText"] length] == 0  && [[activityStoryDictionary valueForKey:@"DescriptionText"] length] == 0 ) {
            valid = NO;
            //has no text to display and is not a picture or video
        }
    }
    NSArray *userArray = [activityStoryDictionary valueForKey:@"Users"];
    for (__strong NSDictionary *userDictionary in userArray) {
        userDictionary = [userDictionary dictionaryByReplacingNullsWithStrings];
        if ([[userDictionary valueForKey:@"UserTypeId"] intValue] == SDUserTypeOrganization) {
            valid = NO;
            //currently we can't display these users
        }
    }
    
    return valid;
}

+ (void)getActivityStoryWithContentId:(NSString *)contentId
                         successBlock:(void (^)(void))successBlock
                         failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"sd/story.json"
                             parameters:@{@"ContentId":contentId}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSArray *activityStories = [JSON valueForKey:@"ActivityStories"];
                                    for (int i = 0; i < [activityStories count]; i++) {
                                        NSDictionary *activityStoryDictionary = [[activityStories objectAtIndex:i] dictionaryByReplacingNullsWithStrings];
                                        NSString *activityStoryContentId = [activityStoryDictionary valueForKey:@"ContentId"];
                                        if ([activityStoryContentId isEqual:contentId])
                                            [self createActivityStoryFromDictionary:activityStoryDictionary
                                                                            context:context];
                                    }
                                    [context MR_saveOnlySelfAndWait];
                                    
                                    if (successBlock) {
                                        successBlock();
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)createActivityStoryFromDictionary:(NSDictionary *)activityStoryDictionary
                                  context:(NSManagedObjectContext *)context
{
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
    NSString *createdDateString = [activityStoryDictionary objectForKey:@"CreatedDate"];
    NSString *lastUpdateDateString = [activityStoryDictionary objectForKey:@"LastUpdatedDate"];
    activityStory.createdDate = [SDUtils dateFromString:createdDateString];
    activityStory.lastUpdateDate = [SDUtils dateFromString:lastUpdateDateString];
    
    activityStory.activityDescription = [activityStoryDictionary valueForKey:@"DescriptionText"];
    activityStory.activityTitle = [activityStoryDictionary valueForKey:@"MessageText"];
    activityStory.mediaType = [activityStoryDictionary valueForKey:@"MediaType"];
    activityStory.thumbnailUrl = [activityStoryDictionary valueForKey:@"ThumbnailUrl"];
    activityStory.mediaUrl = [activityStoryDictionary valueForKey:@"MediaUrl"];
    
    //if has a webpreview then this story contains a link, parse and save this object
    if ([[activityStoryDictionary valueForKey:@"WebPreview"] isKindOfClass:[NSDictionary class]])
        [self createUpdateWebPreviewObjectFromDictionary:[activityStoryDictionary valueForKey:@"WebPreview"] withStory:activityStory inContext:context];
    
    //parse users(actors/authors) in this activity story
    NSArray *userArray = [activityStoryDictionary valueForKey:@"Users"];
    for (NSDictionary *userDictionary in userArray) {
        
        //cycle through array and creates updates users
        NSDictionary *formatedUserDictionary = [userDictionary dictionaryByReplacingNullsWithStrings];
        [self createUpdateUserFromDictionary:formatedUserDictionary withActivityStory:activityStory inContext:context];
    }
}

+ (void)createUpdateWebPreviewObjectFromDictionary:(NSDictionary *)dictionary
                                         withStory:(ActivityStory *)story
                                         inContext:(NSManagedObjectContext *)context
{
    NSString *webPreviewLink = nil;
    
    if ([dictionary objectForKey:@"Link"]) {
        webPreviewLink = [dictionary objectForKey:@"Link"];
        
        WebPreview *webPreview = [WebPreview MR_findFirstByAttribute:@"link" withValue:webPreviewLink inContext:context];
        if (!story.webPreview) {
            webPreview = [WebPreview MR_createInContext:context];
        }
        
        webPreview.link = webPreviewLink;
        webPreview.webPreviewTitle = [dictionary objectForKey:@"Title"];
        webPreview.siteName = [dictionary objectForKey:@"SiteName"];
        //        if ([dictionary objectForKey:@"Excerpt"] != [NSNull null]) {
        //            webPreview.excerpt = [dictionary objectForKey:@"Excerpt"];
        //        }
        webPreview.imageUrl = [dictionary objectForKey:@"ImageUrl"];
        story.webPreview = webPreview;
    }
}

+ (void)createUpdateUserFromDictionary:(NSDictionary *)dictionary
                     withActivityStory:(ActivityStory *)activityStory
                             inContext:(NSManagedObjectContext *)context
{
    NSNumber *authorIdentifier = [NSNumber numberWithInt:[[dictionary valueForKey:@"Id"] intValue]];
    
    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:authorIdentifier inContext:context];
    if (!user) {
        user = [User MR_createInContext:context];
        user.identifier = authorIdentifier;
    }
    user.username = [dictionary valueForKey:@"UserName"];
    user.avatarUrl = [dictionary valueForKey:@"AvatarUrl"];
    user.name = [dictionary valueForKey:@"DisplayName"];
    
    if ([[dictionary valueForKey:@"Verb"] isEqualToString:@"From"]) {
        //this user created this post, assign it as author
        activityStory.author = nil;
        activityStory.author = user;
    }
    if ([[dictionary valueForKey:@"Verb"] isEqualToString:@"For"]) {
        //this is a wall post, activityStory posted on this users wall
        activityStory.postedToUser = nil;
        activityStory.postedToUser = user;
    }
    
    //check user type and save info depending on this type
    
    SDUserType userTypeId = [[dictionary valueForKey:@"UserTypeId"] intValue];
    if (userTypeId > 0) {
        user.userTypeId = [NSNumber numberWithInt:userTypeId];
    }
    
    if ([[dictionary objectForKey:@"Attributes"] isKindOfClass:[NSDictionary class]]) {
    
        NSDictionary *attributeDictionary = [[dictionary objectForKey:@"Attributes"] dictionaryByReplacingNullsWithStrings];
        if (userTypeId == SDUserTypePlayer) {
            //user type: Player
            
            if (attributeDictionary) {
                if (!user.thePlayer)
                    user.thePlayer = [Player MR_createInContext:context];
                user.thePlayer.position = [attributeDictionary valueForKey:@"Position"];
                user.thePlayer.userClass = [[attributeDictionary valueForKey:@"Class"] isKindOfClass:[NSString class]] ? [attributeDictionary valueForKey:@"Class"] : [[attributeDictionary valueForKey:@"Class"] stringValue];
            }
        }
        else if (userTypeId == SDUserTypeTeam) {
            //user type: TEAM
            
            if (attributeDictionary) {
                if (!user.theTeam)
                    user.theTeam = [Team MR_createInContext:context];
                user.theTeam.location = [attributeDictionary valueForKey:@"CityName"];
                user.theTeam.stateCode = [attributeDictionary valueForKey:@"StateCode"];
            }
        }
        else if (userTypeId == SDUserTypeCoach) {
            //user type: Coach
            
            if (attributeDictionary) {
                if (!user.theCoach)
                    user.theCoach = [Coach MR_createInContext:context];
                
                user.theCoach.institution = [attributeDictionary valueForKey:@"Institution"];
            }
        }
        else if (userTypeId == SDUserTypeHighSchool) {
            
            //user type: HighSchool
            
            if (attributeDictionary) {
                if (!user.theHighSchool)
                    user.theHighSchool = [HighSchool MR_createInContext:context];
                
                user.theHighSchool.address = [attributeDictionary valueForKey:@"CityName"];
                user.theHighSchool.stateCode = [attributeDictionary valueForKey:@"StateCode"];
            }
        }
    }
}

+ (void)postActivityStoryWithMessageBody:(NSString *)messageBody
                            successBlock:(void (^)(void))successBlock
                            failureBlock:(void (^)(void))failureBlock
{
    [self postActivityStoryWithMessageBody:messageBody
                                   forUser:nil
                              successBlock:successBlock
                              failureBlock:failureBlock];
}

+ (void)postActivityStoryWithMessageBody:(NSString *)messageBody
                                 forUser:(User *)user
                            successBlock:(void (^)(void))successBlock
                            failureBlock:(void (^)(void))failureBlock
{
    if (!user) {
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        NSDictionary *parameters  = @{@"Username": username,
                                      @"MessageBody": messageBody};
        
        NSString *path = [NSString stringWithFormat:@"users/%@/statuses.json", username];
        [[SDAPIClient sharedClient] postPath:path
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id JSON) {
                                         successBlock();
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         failureBlock();
                                     }];
    } else {
        NSString *identifierString = [NSString stringWithFormat:@"%d", [user.identifier integerValue]];
        [[SDAPIClient sharedClient] postPath:@"sd/wallpost.json"
                                  parameters:@{@"ForUserID": identifierString, @"MessageBody": messageBody}
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         successBlock();
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         failureBlock();
                                     }];
    }
}

+ (void)likeActivityStory:(ActivityStory *)activityStory
             successBlock:(void (^)(void))successBlock
             failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"likes.json"
                              parameters:@{@"ContentId":activityStory.contentId, @"ContentTypeId":activityStory.contentTypeId}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     if (successBlock)
                                         successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [SDErrorService handleError:error withOperation:operation];
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

+ (void)unlikeActivityStory:(ActivityStory *)activityStory
               successBlock:(void (^)(void))successBlock
               failureBlock:(void (^)(void))failureBlock
{
    NSMutableURLRequest *request = [[SDAPIClient sharedClient] requestWithMethod:@"POST"
                                                                            path:@"like.json"
                                                                      parameters:@{@"ContentId":activityStory.contentId}];
    [request addValue:@"DELETE" forHTTPHeaderField:@"Rest-Method"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if (successBlock) {
            successBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SDErrorService handleError:error withOperation:operation];
        failureBlock();
    }];
    
    [operation start];
}

+ (void)addCommentToActivityStory:(ActivityStory *)activityStory
                             text:(NSString *)commentText
                     successBlock:(void (^)(void))successBlock
                     failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"comments.json"
                              parameters:@{@"ContentId":activityStory.contentId, @"ContentTypeId":activityStory.contentTypeId, @"Body":commentText}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSDictionary *commentDictionary = [[JSON valueForKey:@"Comment"] dictionaryByReplacingNullsWithStrings];
                                     __unused Comment *comment = [self createCommentFromDictionary:commentDictionary];
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

+ (void)getCommentsForActivityStory:(ActivityStory *)activityStory
                   withSuccessBlock:(void (^)(void))successBlock
                       failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"comments.json"
                             parameters:@{@"ContentId":activityStory.contentId}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSArray *commentsArray = [JSON valueForKey:@"Comments"];
                                    NSMutableArray *commentsIdsArray = [[NSMutableArray alloc] init];
                                    for (__strong NSDictionary *commentDictionary in commentsArray) {
                                        commentDictionary = [commentDictionary dictionaryByReplacingNullsWithStrings];
                                        Comment *comment = [self createCommentFromDictionary:commentDictionary];
                                        [commentsIdsArray addObject:comment.commentId];
                                    }
                                    NSManagedObjectContext *activityStoryContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                    ActivityStory *activityStoryInContext = [activityStory MR_inContext:activityStoryContext];
                                    activityStoryInContext.commentCount = [NSNumber numberWithInt:[commentsArray count]];
                                    [activityStoryContext MR_saveToPersistentStoreAndWait];
                                    
                                    NSString *stringOfCommentsIds = [commentsIdsArray componentsJoinedByString:@","];
                                    [self replaceMentionsWithPlainTextForCommentsWithIdsSeperatedByCommas:stringOfCommentsIds
                                                                                         withSuccessBlock:^{
                                                                                             if (successBlock)
                                                                                                 successBlock();
                                                                                         } failureBlock:nil];
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"Comments parse failed");
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getLikesForActivityStory:(ActivityStory *)activityStory
                withSuccessBlock:(void (^)(void))successBlock
                    failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"likes.json"
                             parameters:@{@"ContentId": activityStory.contentId}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    
                                    // Synchronization: deletion and re-creation
                                    [self deleteAllLikesFromActivityStory:activityStory];
                                    
                                    NSArray *likesArray = [JSON valueForKey:@"Likes"];
                                    for (__strong NSDictionary *likeDictionary in likesArray) {
                                        likeDictionary = [likeDictionary dictionaryByReplacingNullsWithStrings];
                                        [self createLikeFromDictionary:likeDictionary];
                                    }
                                    successBlock();
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    failureBlock();
                                }];
}

+ (void)replaceMentionsWithPlainTextForCommentsWithIdsSeperatedByCommas:(NSString *)commentsIdsSeperatedByCommas
                                                       withSuccessBlock:(void (^)(void))successBlock
                                                           failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"mentions.json"
                             parameters:@{@"MentioningContentIds":commentsIdsSeperatedByCommas}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSArray *mentionsArray = [JSON valueForKey:@"Mentions"];
                                    for (NSDictionary *mentionDictionary in mentionsArray) {
                                        NSDictionary *mentioningContentDictionary = [mentionDictionary valueForKey:@"MentioningContent"];
                                        NSString *commentId = [mentioningContentDictionary valueForKey:@"ContentId"];
                                        NSString *commentText = [[mentioningContentDictionary valueForKey:@"HtmlDescription"] stringByConvertingHTMLToPlainText];
                                        
                                        Comment *comment = [Comment MR_findFirstByAttribute:@"commentId"
                                                                                  withValue:commentId
                                                                                  inContext:context];
                                        comment.body = commentText;
                                    }
                                    [context MR_saveOnlySelfAndWait];
                                    if (successBlock)
                                        successBlock();
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

#pragma mark - Private methods

+ (Comment *)createCommentFromDictionary:(NSDictionary *)commentDictionary
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
    }
    ActivityStory *activityStory = [ActivityStory MR_findFirstByAttribute:@"contentId"
                                                                withValue:contentId
                                                                inContext:commentsContext];
    comment.activityStory = activityStory;
    
    NSString *commentBody = [commentDictionary valueForKey:@"Body"];
    comment.body = [commentBody stringByConvertingHTMLToPlainText];
    
    NSDictionary *userDictionary = [[commentDictionary valueForKey:@"User"] dictionaryByReplacingNullsWithStrings];
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
    user.name = [[userDictionary valueForKey:@"DisplayName"] stringByConvertingHTMLToPlainText];
    comment.user = user;
    
    NSString *updatedDateString = [[commentDictionary objectForKey:@"UpdatedDate"] stringByDeletingPathExtension];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSDate *updatedDate = [dateFormatter dateFromString:updatedDateString];
    comment.updatedDate = updatedDate;
    
    [commentsContext MR_saveToPersistentStoreAndWait];
    
    return comment;
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
    NSDictionary *userDictionary = [[likeDictionary valueForKey:@"User"] dictionaryByReplacingNullsWithStrings];
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

+ (void)markAllStoriesForDeletionInContext:(NSManagedObjectContext *)context
{
    NSArray *allStories = [ActivityStory MR_findAllInContext:context];
    
    for (ActivityStory *story in allStories) {
        story.shouldBeDeleted = [NSNumber numberWithBool:YES];
    }
    [context MR_saveOnlySelfAndWait];
}

+ (void)deleteAllMarkedStoriesInContext:(NSManagedObjectContext *)context
{
    NSArray *allStories = [ActivityStory MR_findAllInContext:context];
    
    for (ActivityStory *story in allStories) {
        if ([story.shouldBeDeleted boolValue]) {
            [context deleteObject:story];
        }
    }
    [context MR_saveOnlySelfAndWait];
}

+ (void)deleteAllLikesFromActivityStory:(ActivityStory *)activityStory
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *likesArray = [Like MR_findByAttribute:@"activityStory.identifier"
                                         withValue:activityStory.identifier
                                         inContext:context];
    for (Like *like in likesArray) {
        [context deleteObject:like];
    }
    
    [context MR_saveToPersistentStoreAndWait];
}

@end