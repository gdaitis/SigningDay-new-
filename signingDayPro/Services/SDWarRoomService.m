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

@implementation SDWarRoomService

#pragma mark - Get Offers for User
+ (void)getWarRoomsWithCompletionBlock:(void (^)(void))completionBlock
                          failureBlock:(void (^)(void))failureBlock
{

    [[SDAPIClient sharedClient] getPath:@"forums.json"
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSLog(@"json = %@",JSON);
                                    
                                    
                                    
                                    
                                    [context MR_saveOnlySelfAndWait];
                                    if (completionBlock) {
                                        completionBlock();
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)startHTTPRequestOperationWithURLString:(NSString *)URLString
                         operationSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))operationSuccessBlock
                         operationFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))operationFailureBlock
{
    URLString = [[[URLString stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"$" withString:@"%24"] stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operationSuccessBlock)
            operationSuccessBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operationFailureBlock)
            operationFailureBlock(operation, error);
    }];
    [operation start];
}

@end
