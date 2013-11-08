//
//  SDWarRoomService.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/21/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Thread;

typedef enum {
    SDEmotionHate = 0,
    SDEmotionBelieve = 1
} SDEmotion;

typedef enum {
    SDForumPostTypeThread = 0,
    SDForumPostTypeReply = 1
} SDForumPostType;

@interface SDWarRoomService : NSObject

+ (void)getWarRoomGroupsWithCompletionBlock:(void (^)(void))completionBlock
                               failureBlock:(void (^)(void))failureBlock;
+ (void)getGroupForumsWithGroupId:(NSNumber *)identifier
                        pageIndex:(NSInteger)pageIndex
                         pageSize:(NSInteger)pageSize
                  completionBlock:(void (^)(NSInteger totalCount))completionBlock
                     failureBlock:(void (^)(void))failureBlock;
+ (void)getForumThreadsWithForumId:(NSNumber *)identifier
                         pageIndex:(NSInteger)pageIndex
                          pageSize:(NSInteger)pageSize
                   completionBlock:(void (^)(NSInteger totalCount))completionBlock
                      failureBlock:(void (^)(void))failureBlock;
+ (void)getForumRepliesWithThreadId:(NSNumber *)identifier
                    completionBlock:(void (^)(void))completionBlock
                       failureBlock:(void (^)(void))failureBlock;
+ (void)postForumReplyForThreadId:(NSNumber *)threadId
                             text:(NSString *)text
                  completionBlock:(void (^)(void))completionBlock
                     failureBlock:(void (^)(void))failureBlock;
+ (void)postNewPorumThreadForForumId:(NSNumber *)forumId
                             subject:(NSString *)subject
                                text:(NSString *)text
                     completionBlock:(void (^)(Thread *thread))completionBlock
                        failureBlock:(void (^)(void))failureBlock;
+ (void)setEmotion:(SDEmotion)emotion
   toForumPostType:(SDForumPostType)forumPostType
    withIdentifier:(NSNumber *)identifier
withCompletionBlock:(void (^)(void))completionBlock
      failureBlock:(void (^)(void))failureBlock;

@end
