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
#import "NSString+HTML.h"

@interface SDWarRoomService ()

+ (void)markAllObjectsForDeletion:(NSArray *)forumItemArray;
+ (void)deleteMarkedObjectsInArray:(NSArray *)array inContext:(NSManagedObjectContext *)context;

@end

@implementation SDWarRoomService

+ (void)getWarRoomGroupsWithCompletionBlock:(void (^)(void))completionBlock
                               failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"groups/7/groups.json" // 7 is an ID of war rooms group
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    [self markAllObjectsForDeletion:[Group MR_findAll]];
                                    
                                    NSArray *groupsArray = [JSON valueForKey:@"Groups"];
                                    for (NSDictionary *groupDictionary in groupsArray) {
                                        __unused Group *group = [self createGroupFromDictionary:groupDictionary
                                                                                      inContext:context];
                                    }
                                    
                                    [self deleteMarkedObjectsInArray:[Group MR_findAll] inContext:context];
                                    
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
                                          @"PageIndex":[NSString stringWithFormat:@"%d", pageIndex],
                                          @"SortBy":@"Name"}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    Group *parentGroup = [Group MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                    
                                    if (pageIndex == 0)
                                    [self markAllObjectsForDeletion:[parentGroup.forums allObjects]];
                                    
                                    NSArray *forumsArray = [JSON valueForKey:@"Forums"];
                                    for (__strong NSDictionary *forumDictionary in forumsArray) {
                                        forumDictionary = [forumDictionary dictionaryByReplacingNullsWithStrings];
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
                                        forum.shouldBeDeleted = [NSNumber numberWithBool:NO];
                                        
                                        NSDictionary *groupDictionary = [forumDictionary valueForKey:@"Group"];
                                        Group *group = [self createGroupFromDictionary:groupDictionary
                                                                             inContext:context];
                                        
                                        forum.group = group;
                                    }
                                    
                                    if (pageIndex == 0)
                                    [self deleteMarkedObjectsInArray:[parentGroup.forums allObjects] inContext:context];
                                    
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
                                          @"PageIndex":[NSString stringWithFormat:@"%d", pageIndex],
                                          @"SortBy":@"Subject"}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    Forum *parentForum = [Forum MR_findFirstByAttribute:@"identifier" withValue:forumIdentifier inContext:context];
                                    
                                    if (pageIndex == 0)
                                    [self markAllObjectsForDeletion:[parentForum.threads allObjects]];
                                    
                                    NSArray *threadsArray = [JSON valueForKey:@"Threads"];
                                    for (__strong NSDictionary *threadDictionary in threadsArray) {
                                        __unused Thread *trhead = [self createThreadFromDictionary:threadDictionary inContext:context];
                                    }
                                    
                                    if (pageIndex == 0)
                                    [self deleteMarkedObjectsInArray:[parentForum.threads allObjects] inContext:context];
                                    
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
                    completionBlock:(void (^)(void))completionBlock
                       failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"sd/forums.json"
                             parameters:@{@"ThreadId":[NSString stringWithFormat:@"%d", [identifier integerValue]]}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    
                                    NSDictionary *threadDictionary = [[JSON valueForKey:@"Thread"] dictionaryByReplacingNullsWithStrings];
                                    // Not using createThreadFromDictionary, cuz it's a custom service with different names of params
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
                                    thread.bodyText = [[threadDictionary valueForKey:@"Text"] stringByConvertingHTMLToPlainText];
                                    thread.shouldBeDeleted = [NSNumber numberWithBool:NO];
                                    
                                    NSDictionary *authorDictionary = [threadDictionary valueForKey:@"Author"];
                                    User *author = [self createUserFromDictionary:authorDictionary
                                                                        inContext:context];
                                    thread.authorUser = author;
                                    
                                    [self markAllObjectsForDeletion:[thread.forumReplies allObjects]];
                                    
                                    NSArray *repliesArray = [JSON valueForKey:@"Replies"];
                                    for (__strong NSDictionary *replyDictionary in repliesArray) {
                                        
                                        replyDictionary = [replyDictionary dictionaryByReplacingNullsWithStrings];
                                        
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
                                        reply.bodyText = [[replyDictionary valueForKey:@"Text"] stringByConvertingHTMLToPlainText];
                                        reply.shouldBeDeleted = [NSNumber numberWithBool:NO];
                                        
                                        NSDictionary *authorDictionary = [replyDictionary valueForKey:@"Author"];
                                        User *author = [self createUserFromDictionary:authorDictionary
                                                                            inContext:context];
                                        reply.authorUser = author;
                                        reply.thread = thread;
                                    }
#warning doesn't work!
                                    [self deleteMarkedObjectsInArray:[thread.forumReplies allObjects] inContext:context];
                                    
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

+ (void)postForumReplyForThreadId:(NSNumber *)threadId
                             text:(NSString *)text
                  completionBlock:(void (^)(void))completionBlock
                     failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"forums/threads/%d/replies.json", [threadId integerValue]];
    [[SDAPIClient sharedClient] postPath:path
                              parameters:@{@"ThreadId": [NSString stringWithFormat:@"%d", [threadId integerValue]],
                                           @"Body": text}
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if (completionBlock)
                                         completionBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

+ (void)postNewPorumThreadForForumId:(NSNumber *)forumId
                             subject:(NSString *)subject
                                text:(NSString *)text
                     completionBlock:(void (^)(Thread *thread))completionBlock
                        failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"forums/%d/threads.json", [forumId integerValue]];
    [[SDAPIClient sharedClient] postPath:path
                              parameters:@{@"ForumId": [NSString stringWithFormat:@"%d", [forumId integerValue]],
                                           @"Subject": subject,
                                           @"Body": text}
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                     NSDictionary *threadDictionary = [JSON valueForKey:@"Thread"];
                                     Thread *thread = [self createThreadFromDictionary:threadDictionary inContext:context];
                                     [context MR_saveOnlySelfAndWait];
                                     if (completionBlock)
                                         completionBlock(thread);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

#pragma mark - Private methods

+ (Group *)createGroupFromDictionary:(NSDictionary *)groupDictionary
                           inContext:(NSManagedObjectContext *)context
{
    groupDictionary = [groupDictionary dictionaryByReplacingNullsWithStrings];
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
    group.shouldBeDeleted = [NSNumber numberWithBool:NO];
    
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
    user.isSDStaff = [NSNumber numberWithBool:[[userDictionary valueForKey:@"IsSdStaff"] boolValue]];
    
    return user;
}

+ (Thread *)createThreadFromDictionary:(NSDictionary *)threadDictionary
                             inContext:(NSManagedObjectContext *)context
{
    threadDictionary = [threadDictionary dictionaryByReplacingNullsWithStrings];
    NSNumber *identifier = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"Id"] integerValue]];
    Thread *thread = [Thread MR_findFirstByAttribute:@"identifier"
                                           withValue:identifier
                                           inContext:context];
    if (!thread) {
        thread = [Thread MR_createInContext:context];
        thread.identifier = identifier;
    }
    thread.bodyText = [[threadDictionary valueForKey:@"Body"] stringByConvertingHTMLToPlainText];
    thread.date = [SDUtils dateFromString:[threadDictionary valueForKey:@"Date"]];
    thread.latestPostDate = [SDUtils dateFromString:[threadDictionary valueForKey:@"LatestPostDate"]];
    thread.subject = [threadDictionary valueForKey:@"Subject"];
    thread.replyCount = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"ReplyCount"] integerValue]];
    thread.shouldBeDeleted = [NSNumber numberWithBool:NO];
    
    NSNumber *forumIdentifier = [NSNumber numberWithInteger:[[threadDictionary valueForKey:@"ForumId"] integerValue]];
    
    Forum *forum = [Forum MR_findFirstByAttribute:@"identifier"
                                        withValue:forumIdentifier
                                        inContext:context];
    if (forum)
        thread.forum = forum;
    
    NSDictionary *authorDictionary = [threadDictionary valueForKey:@"Author"];
    User *author = [self createUserFromDictionary:authorDictionary
                                        inContext:context];
    thread.authorUser = author;
    
    return thread;
}

#pragma mark - private methods

+ (void)markAllObjectsForDeletion:(NSArray *)forumItemArray
{
    if (forumItemArray) {
        for (id forumListItem in forumItemArray) {
            
            if ([forumListItem valueForKey:@"shouldBeDeleted"]) {
                if ([[forumListItem valueForKey:@"shouldBeDeleted"] isKindOfClass:[NSNumber class]]) {
                    [forumListItem setValue:[NSNumber numberWithBool:YES] forKey:@"shouldBeDeleted"];
                }
            }
        }
    }
}


+ (void)deleteMarkedObjectsInArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    for (id forumListItem in array) {
        
        if ([forumListItem valueForKey:@"shouldBeDeleted"]) {
            if ([[forumListItem valueForKey:@"shouldBeDeleted"] isKindOfClass:[NSNumber class]]) {
                if ([[forumListItem valueForKey:@"shouldBeDeleted"] boolValue]) {
                    [context deleteObject:forumListItem];
                }
            }
        }
    }
}

@end
