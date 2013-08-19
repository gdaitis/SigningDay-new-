//
//  SDActivityFeedService.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActivityStory;
@class Comment;
@class User;

@interface SDActivityFeedService : NSObject

+ (void)getActivityStoriesForUser:(User *)user
                         withDate:(NSDate *)date
                     andDeleteOld:(BOOL)deleteOld
                 withSuccessBlock:(void (^)(NSDictionary *results))successBlock
                     failureBlock:(void (^)(void))failureBlock;
+ (void)postActivityStoryWithMessageBody:(NSString *)messageBody
                            successBlock:(void (^)(void))successBlock
                            failureBlock:(void (^)(void))failureBlock;
+ (void)postActivityStoryWithMessageBody:(NSString *)messageBody
                                 forUser:(User *)user
                            successBlock:(void (^)(void))successBlock
                            failureBlock:(void (^)(void))failureBlock;
+ (void)likeActivityStory:(ActivityStory *)activityStory
             successBlock:(void (^)(void))successBlock
             failureBlock:(void (^)(void))failureBlock;
+ (void)unlikeActivityStory:(ActivityStory *)activityStory
               successBlock:(void (^)(void))successBlock
               failureBlock:(void (^)(void))failureBlock;
+ (void)addCommentToActivityStory:(ActivityStory *)activityStory
                             text:(NSString *)commentText
                     successBlock:(void (^)(void))successBlock
                     failureBlock:(void (^)(void))failureBlock;
+ (void)removeComment:(Comment *)comment
         successBlock:(void (^)(void))successBlock
         failureBlock:(void (^)(void))failureBlock;
+ (void)getCommentsForActivityStory:(ActivityStory *)activityStory
                   withSuccessBlock:(void (^)(void))successBlock
                       failureBlock:(void (^)(void))failureBlock;
+ (void)getLikesForActivityStory:(ActivityStory *)activityStory
                withSuccessBlock:(void (^)(void))successBlock
                    failureBlock:(void (^)(void))failureBlock;

//delete all stories
+ (void)deleteAllActivityStories;

@end
