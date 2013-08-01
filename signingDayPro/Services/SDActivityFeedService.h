//
//  SDActivityFeedService.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    SDUserTypePlayer = 1,
    SDUserTypeTeam = 2,
    SDUserTypeCoach = 3,
    SDUserTypeHighSchool = 4,
    SDUserTypeMember = 5
} SDUserType;

@class ActivityStory;
@class Comment;
@class User;

@interface SDActivityFeedService : NSObject

+ (void)getActivityStoriesForUser:(User *)user
                         withDate:(NSDate *)date
                  shouldDeleteOld:(BOOL)deleteOld
                 withSuccessBlock:(void (^)(NSDictionary *results))successBlock
                     failureBlock:(void (^)(void))failureBlock;
+ (void)postActivityStoryWithMessageBody:(NSString *)messageBody
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

//delete all stories
+ (void)deleteAllActivityStories;

@end
