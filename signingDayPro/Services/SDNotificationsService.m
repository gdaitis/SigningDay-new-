//
//  SDNotificationsService.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/25/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNotificationsService.h"
#import "SDAPIClient.h"
#import "Master.h"
#import "User.h"
#import "Notification.h"
#import "NSDictionary+NullConverver.h"
#import "SDUtils.h"
#import "NSObject+MasterUserMethods.h"

NSString * const SDNotificationsServiceCountOfUnreadNotifications = @"SDNotificationsServiceCountOfUnreadNotifications";
NSString * const SDNotificationsServiceCountOfUnreadConversations = @"SDNotificationsServiceCountOfUnreadConversations";
NSString * const SDNotificationsServiceCountOfUnreadFollowers = @"SDNotificationsServiceCountOfUnreadFollowers";

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
                                success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                    responseObject = [responseObject dictionaryByReplacingNullsWithStrings];
                                    NSArray *notificationsArray;
                                    if (![[responseObject objectForKey:@"Notifications"] isEqual:@""])
                                        notificationsArray = [responseObject objectForKey:@"Notifications"];
                                    else
                                        notificationsArray = nil;
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    for (NSDictionary __strong *notificationDictionary in notificationsArray) {
                                        notificationDictionary = [notificationDictionary dictionaryByReplacingNullsWithStrings];
                                        NSNumber *identifier = [NSNumber numberWithInt:[[notificationDictionary valueForKey:@"ID"] intValue]];
                                        
                                        Notification *notification = [Notification MR_findFirstByAttribute:@"identifier"
                                                                                                 withValue:identifier
                                                                                                 inContext:context];
                                        if (!notification) {
                                            notification = [Notification MR_createInContext:context];
                                            notification.identifier = identifier;
                                        }
                                        notification.contentId = [notificationDictionary valueForKey:@"ContentID"];
                                        notification.contentTypeId = [notificationDictionary valueForKey:@"ContentTypeID"];
                                        notification.contentTypeName = [notificationDictionary valueForKey:@"ContentTypeName"];
                                        notification.createdDate = [SDUtils dateFromString:[notificationDictionary valueForKey:@"CreatedOn"]];
                                        notification.isNew = [NSNumber numberWithBool:[[notificationDictionary valueForKey:@"IsNew"] boolValue]];
                                        notification.notificationTypeId = [NSNumber numberWithInt:[[notificationDictionary valueForKey:@"NotificationTypeID"] intValue]];
                                        
                                        NSString *activityStoryId = @"";
                                        NSArray *urlContents = [[notificationDictionary valueForKey:@"Url"] componentsSeparatedByString:@"?"];
                                        for (NSString *string in urlContents) {
                                            if ([string hasPrefix:@"ActivityMessageID="]) {
                                                activityStoryId = [string stringByReplacingOccurrencesOfString:@"ActivityMessageID=" withString:@""];
                                                break;
                                            }
                                        }
                                        if (![activityStoryId isEqual:@""]) {
                                            notification.activityStoryId = activityStoryId;
                                        }
                                        
                                        NSNumber *masterIdentifier = [NSNumber numberWithInt:[[notificationDictionary valueForKey:@"ForUserID"] intValue]];
                                        Master *master = [Master MR_findFirstByAttribute:@"identifier"
                                                                               withValue:masterIdentifier
                                                                               inContext:context];
                                        if (!master) {
                                            master = [Master MR_createInContext:context];
                                            master.identifier = masterIdentifier;
                                        }
                                        notification.master = master;
                                        
                                        NSDictionary *fromUserDictionary = [notificationDictionary valueForKey:@"FromUser"];
                                        NSNumber *fromUserIdentifier = [NSNumber numberWithInt:[[fromUserDictionary valueForKey:@"FromUserID"] intValue]];
                                        User *fromUser = [User MR_findFirstByAttribute:@"identifier"
                                                                             withValue:fromUserIdentifier
                                                                             inContext:context];
                                        if (!fromUser) {
                                            fromUser = [User MR_createInContext:context];
                                            fromUser.identifier = fromUserIdentifier;
                                        }
                                        fromUser.name = [fromUserDictionary valueForKey:@"DisplayName"];
                                        fromUser.avatarUrl = [fromUserDictionary valueForKey:@"AvatarUrl"];
                                        fromUser.userTypeId = [fromUserDictionary valueForKey:@"UserTypeId"];
                                        notification.fromUser = fromUser;
                                        
                                    }
                                    [context MR_saveOnlySelfAndWait];
                                    if (successBlock)
                                        successBlock();
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)markAllNotificationsReadWithSuccessBlock:(void (^)(void))successBlock
                                    failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] postPath:@"sd/notifications.json"
                              parameters:nil
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     NSArray *notificationIdentifiersStringsArray = [responseObject valueForKey:@"Notifications"];
                                     if (![notificationIdentifiersStringsArray isKindOfClass:[NSNull class]]) {
                                         NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                         for (NSString *notificationIdentifierString in notificationIdentifiersStringsArray) {
                                             NSNumber *identifier = [NSNumber numberWithInt:[notificationIdentifierString intValue]];
                                             Notification *notification = [Notification MR_findFirstByAttribute:@"identifier"
                                                                                                      withValue:identifier
                                                                                                      inContext:context];
                                             if (!notification) {
                                                 notification = [Notification MR_createInContext:context];
                                                 notification.identifier = identifier;
                                             }
                                             notification.isNew = [NSNumber numberWithBool:NO];
                                         }
                                         [context MR_saveOnlySelfAndWait];
                                     }
                                     if (successBlock)
                                         successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

+ (void)getCountOfUnreadNotificationsWithSuccessBlock:(void (^)(NSDictionary *unreadNotificationsCountDictionary))successBlock
                                         failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"sd/unread.json"
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSMutableDictionary *unreadNotificationsCountDictionary = [[NSMutableDictionary alloc] init];
                                    NSNumber *countOfUnreadConversations = [NSNumber numberWithInt:[[responseObject valueForKey:@"NewConversations"] intValue]];
                                    NSNumber *countOfUnreadFollowers = [NSNumber numberWithInt:[[responseObject valueForKey:@"NewFollowers"] intValue]];
                                    NSNumber *countOfUnreadNotifications = [NSNumber numberWithInt:[[responseObject valueForKey:@"NewNotifications"] intValue]];
                                    [unreadNotificationsCountDictionary setObject:countOfUnreadConversations forKey:SDNotificationsServiceCountOfUnreadConversations];
                                    [unreadNotificationsCountDictionary setObject:countOfUnreadFollowers forKey:SDNotificationsServiceCountOfUnreadFollowers];
                                    [unreadNotificationsCountDictionary setObject:countOfUnreadNotifications forKey:SDNotificationsServiceCountOfUnreadNotifications];
                                    if (successBlock)
                                        successBlock(unreadNotificationsCountDictionary);
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

@end
