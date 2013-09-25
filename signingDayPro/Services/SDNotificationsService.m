//
//  SDNotificationsService.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/25/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNotificationsService.h"
#import "SDAPIClient.h"

NSString * const SDNotificationsServiceNotificationTypeNotifications = @"SDNotificationsServiceNotificationTypeNotifications";
NSString * const SDNotificationsServiceNotificationTypeConversations = @"SDNotificationsServiceNotificationTypeConversations";
NSString * const SDNotificationsServiceNotificationTypeFollowers = @"SDNotificationsServiceNotificationTypeFollowers";

@implementation SDNotificationsService

+ (void)getNotificationsWithPageSize:(NSNumber *)pageSize
                        successBlock:(void (^)(void))successBlock
                        failureBlock:(void (^)(void))failureBlock
{
    NSDictionary *parameters = nil;
    if (pageSize) {
        NSString *pageSizeString = [NSString stringWithFormat:@"%d", [pageSize integerValue]];
        parameters = @{@"PageSize": pageSizeString};
    }
    [[SDAPIClient sharedClient] getPath:@"sd/notifications.json"
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    if (successBlock)
                                        successBlock();
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)markAllNotificationsReadWithSuccessBlock:(void (^)(NSArray *markedNotifications))successBlock
                                    failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"sd/notifications.json"
                              parameters:nil
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     /*if (successBlock)
                                         successBlock(array);*/
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

+ (void)getCountOfUnreadNotificationsWithSuccessBlock:(void (^)(NSDictionary *markedNotifications))successBlock
                                         failureBlock:(void (^)(void))failureBlock
{
    
}

@end
