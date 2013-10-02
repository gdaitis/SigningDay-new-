//
//  SDNotificationsService.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/25/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SDNotificationTypeLike = 1,
    SDNotificationTypeComment = 2,
    SDNotificationTypeForumReply = 3,
    SDNotificationTypeMention = 4,
    SDNotificationTypeForumPost = 5,
    SDNotificationTypeFollowing = 6,
    SDNotificationTypeBuzzBoard = 7
} SDNotificationType;

NSString * const SDNotificationsServiceCountOfUnreadNotifications;
NSString * const SDNotificationsServiceCountOfUnreadConversations;
NSString * const SDNotificationsServiceCountOfUnreadFollowers;

@interface SDNotificationsService : NSObject

+ (void)getNotificationsWithPageSize:(NSNumber *)pageSize
                        successBlock:(void (^)(void))successBlock
                        failureBlock:(void (^)(void))failureBlock;
+ (void)markAllNotificationsReadWithSuccessBlock:(void (^)(void))successBlock
                                    failureBlock:(void (^)(void))failureBlock;
+ (void)getCountOfUnreadNotificationsWithSuccessBlock:(void (^)(NSDictionary *unreadNotificationsCountDictionary))successBlock
                                         failureBlock:(void (^)(void))failureBlock;

@end