//
//  SDNotificationsService.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/25/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

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
