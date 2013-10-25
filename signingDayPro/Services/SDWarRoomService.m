//
//  SDWarRoomService.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/21/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDWarRoomService.h"
#import <AFNetworking/AFNetworking.h>
#import "SDAPIClient.h"
#import "NSDictionary+NullConverver.h"
#import "User.h"
#import "Group.h"
#import "Forum.h"
#import "ForumReply.h"
#import "Thread.h"
#import "SDUtils.h"

@implementation SDWarRoomService

+ (void)getWarRoomGroupsWithCompletionBlock:(void (^)(void))completionBlock
                               failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"groups/7/groups.json" // 7 is an ID of war rooms group
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    NSArray *groupsArray = [JSON valueForKey:@"Groups"];
                                    for (NSDictionary *groupDictionary in groupsArray) {
                                        __unused Group *group = [self createGroupFromDictionary:groupDictionary
                                                                             inContext:context];
                                    }
                                    
                                    [context MR_saveOnlySelfAndWait];
                                    if (completionBlock) {
                                        completionBlock();
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getGroupForumsWithGroupId:(NSNumber *)identifier
                        pageIndex:(NSInteger)pageIndex
                         pageSize:(NSInteger)pageSize
                  completionBlock:(void (^)(NSInteger totalCount))completionBlock
                     failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:[NSString stringWithFormat:@"groups/%d/forums.json", [identifier integerValue]]
                             parameters:@{@"PageSize":[NSString stringWithFormat:@"%d", pageSize],
                                          @"PageIndex":[NSString stringWithFormat:@"%d", pageIndex]}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    NSArray *forumsArray = [JSON valueForKey:@"Forums"];
                                    for (NSDictionary *forumDictionary in forumsArray) {
                                        NSNumber *identifier = [NSNumber numberWithInteger:[[forumDictionary valueForKey:@"Id"] integerValue]];
                                        Forum *forum = [Forum MR_findFirstByAttribute:@"identifier"
                                                                            withValue:identifier
                                                                            inContext:context];
                                        if (!forum) {
                                            forum = [Forum MR_createInContext:context];
                                            forum.identifier = identifier;
                                        }
                                        forum.dateCreated = [SDUtils dateFromString:[forumDictionary valueForKey:@"DateCreated"]];
                                        forum.forumDescription = [forumDictionary valueForKey:@"Description"];
                                        forum.latestPostDate = [SDUtils dateFromString:[forumDictionary valueForKey:@"LatestPostDate"]];
                                        forum.enabled = [NSNumber numberWithBool:[[forumDictionary valueForKey:@"Enabled"] boolValue]];
                                        forum.name = [forumDictionary valueForKey:@"Name"];
                                        forum.replyCount = [NSNumber numberWithInteger:[[forumDictionary valueForKey:@"ReplyCount"] integerValue]];
                                        forum.threadCount = [NSNumber numberWithInteger:[[forumDictionary valueForKey:@"ThreadCount"] integerValue]];
                                        
                                        NSDictionary *groupDictionary = [forumDictionary valueForKey:@"Group"];
                                        Group *group = [self createGroupFromDictionary:groupDictionary
                                                                             inContext:context];
                                        
                                        forum.group = group;
                                    }
                                    
                                    [context MR_saveOnlySelfAndWait];
                                    NSInteger totalCount = [[JSON valueForKey:@"TotalCount"] integerValue];
                                    if (completionBlock) {
                                        completionBlock(totalCount);
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getForumThreadsWithForumId:(NSNumber *)identifier
                         pageIndex:(NSInteger)pageIndex
                          pageSize:(NSInteger)pageSize
                   completionBlock:(void (^)(NSInteger totalCount))completionBlock
                      failureBlock:(void (^)(void))failureBlock
{
    __block NSNumber *forumIdentifier = identifier;
    [[SDAPIClient sharedClient] getPath:[NSString stringWithFormat:@"forums/%d/threads.json", [identifier integerValue]]
                             parameters:@{@"PageSize":[NSString stringWithFormat:@"%d", pageSize],
                                          @"PageIndex":[NSString stringWithFormat:@"%d", pageIndex]}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    NSArray *threadsArray = [JSON valueForKey:@"Threads"];
                                    for (NSDictionary *threadDictionary in threadsArray) {
                                        NSNumber *identifier = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"Id"] integerValue]];
                                        Thread *thread = [Thread MR_findFirstByAttribute:@"identifier"
                                                                               withValue:identifier
                                                                               inContext:context];
                                        if (!thread) {
                                            thread = [Thread MR_createInContext:context];
                                            thread.identifier = identifier;
                                        }
                                        thread.bodyText = [threadDictionary valueForKey:@"Body"];
                                        thread.date = [SDUtils dateFromString:[threadDictionary valueForKey:@"Date"]];
                                        thread.latestPostDate = [SDUtils dateFromString:[threadDictionary valueForKey:@"LatestPostDate"]];
                                        thread.subject = [threadDictionary valueForKey:@"Subject"];
                                        thread.replyCount = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"ReplyCount"] integerValue]];
                                        
                                        Forum *forum = [Forum MR_findFirstByAttribute:@"identifier"
                                                                            withValue:forumIdentifier
                                                                            inContext:context];
                                        if (forum)
                                            thread.forum = forum;
                                        
                                        NSDictionary *authorDictionary = [threadDictionary valueForKey:@"Author"];
                                        User *author = [self createUserFromDictionary:authorDictionary
                                                                            inContext:context];
                                        thread.authorUser = author;
                                    }
                                    
                                    [context MR_saveOnlySelfAndWait];
                                    NSInteger totalCount = [[JSON valueForKey:@"TotalCount"] integerValue];
                                    if (completionBlock) {
                                        completionBlock(totalCount);
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getForumRepliesWithThreadId:(NSNumber *)identifier
                    completionBlock:(void (^)())completionBlock
                       failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"sd/forums.json"
                             parameters:@{@"ThreadId":[NSString stringWithFormat:@"%d", [identifier integerValue]]}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    NSDictionary *threadDictionary = [JSON valueForKey:@"Thread"];
                                    NSNumber *threadIdentifier = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"ThreadId"] integerValue]];
                                    Thread *thread = [Thread MR_findFirstByAttribute:@"identifier"
                                                                           withValue:threadIdentifier
                                                                           inContext:context];
                                    if (!thread) {
                                        thread = [Thread MR_createInContext:context];
                                        thread.identifier = threadIdentifier;
                                    }
                                    thread.countOfBelieves = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"BelievesCount"] integerValue]];
                                    thread.countOfHates = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"HatesCount"] integerValue]];
                                    thread.date = [SDUtils dateFromString:[threadDictionary valueForKey:@"PostDate"]];
                                    thread.subject = [threadDictionary valueForKey:@"Subject"];
                                    thread.bodyText = [threadDictionary valueForKey:@"Text"];
                                    
                                    NSDictionary *authorDictionary = [threadDictionary valueForKey:@"Author"];
                                    User *author = [self createUserFromDictionary:authorDictionary
                                                                        inContext:context];
                                    thread.authorUser = author;
                                    
                                    NSArray *repliesArray = [JSON valueForKey:@"Replies"];
                                    for (NSDictionary *replyDictionary in repliesArray) {
                                        NSNumber *replyIdentifier = [NSNumber numberWithInteger:[[replyDictionary valueForKey:@"Id"] integerValue]];
                                        ForumReply *reply = [ForumReply MR_findFirstByAttribute:@"identifier"
                                                                                      withValue:replyIdentifier
                                                                                      inContext:context];
                                        if (!reply) {
                                            reply = [ForumReply MR_createInContext:context];
                                            reply.identifier = replyIdentifier;
                                        }
                                        reply.countOfBelieves = [NSNumber numberWithInteger:[[replyDictionary valueForKey:@"BelievesCount"] integerValue]];
                                        reply.countOfHates = [NSNumber numberWithInteger:[[replyDictionary valueForKey:@"HatesCount"] integerValue]];
                                        reply.date = [SDUtils dateFromString:[replyDictionary valueForKey:@"PostDate"]];
                                        reply.subject = [replyDictionary valueForKey:@"Subject"];
                                        reply.bodyText = [replyDictionary valueForKey:@"Text"];
                                        
                                        NSDictionary *authorDictionary = [replyDictionary valueForKey:@"Author"];
                                        User *author = [self createUserFromDictionary:authorDictionary
                                                                            inContext:context];
                                        reply.authorUser = author;
                                    }
                                    
                                    [context MR_saveOnlySelfAndWait];
                                    if (completionBlock) {
                                        completionBlock();
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)setEmotion:(SDEmotion)emotion
   toForumPostType:(SDForumPostType)forumPostType
    withIdentifier:(NSNumber *)identifier
withCompletionBlock:(void (^)(void))completionBlock
      failureBlock:(void (^)(void))failureBlock
{
    NSString *path;
    NSString *emotionIdParameterName;
    switch (emotion) {
        case SDEmotionBelieve:
            path = @"sd/believers.json";
            emotionIdParameterName = @"BelieverID";
            break;
            
        case SDEmotionHate:
            path = @"sd/haters.json";
            emotionIdParameterName = @"HaterID";
            break;
            
        default:
            break;
    }
    
    NSString *identifierParameterName;
    switch (forumPostType) {
        case SDForumPostTypeThread:
            identifierParameterName = @"ThreadId";
            break;
            
        case SDForumPostTypeReply:
            identifierParameterName = @"ThreadReplyId";
            break;
            
        default:
            break;
    }
    
    [[SDAPIClient sharedClient] postPath:path
                              parameters:@{identifierParameterName: [NSString stringWithFormat:@"%d", [identifier integerValue]],
                                           emotionIdParameterName: @2100}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     if (completionBlock) {
                                         completionBlock();
                                     }
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

#pragma mark - Private methods

+ (Group *)createGroupFromDictionary:(NSDictionary *)groupDictionary
                           inContext:(NSManagedObjectContext *)context
{
    NSNumber *identifier = [NSNumber numberWithInteger:[[groupDictionary valueForKey:@"Id"] integerValue]];
    Group *group = [Group MR_findFirstByAttribute:@"identifier"
                                        withValue:identifier
                                        inContext:context];
    if (!group) {
        group = [Group MR_createInContext:context];
        group.identifier = identifier;
    }
    group.avatarUrl = [groupDictionary valueForKey:@"AvatarUrl"];
    group.dateCreated = [SDUtils dateFromString:[groupDictionary valueForKey:@"DateCreated"]];
    group.groupDescription = [groupDictionary valueForKey:@"Description"];
    group.isEnabled = [NSNumber numberWithBool:[[groupDictionary valueForKey:@"IsEnabled"] boolValue]];
    group.name = [groupDictionary valueForKey:@"Name"];
    
    return group;
}

+ (User *)createUserFromDictionary:(NSDictionary *)userDictionary
                         inContext:(NSManagedObjectContext *)context
{
    NSNumber *userIdentifier = [NSNumber numberWithInteger:[[userDictionary valueForKey:@"Id"] integerValue]];
    User *user = [User MR_findFirstByAttribute:@"identifier"
                                     withValue:userIdentifier
                                     inContext:context];
    if (!user) {
        user = [User MR_createInContext:context];
        user.identifier = userIdentifier;
    }
    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
    user.name = [userDictionary valueForKey:@"DisplayName"];
    user.username = [userDictionary valueForKey:@"Username"];
    
    return user;
}

@end
