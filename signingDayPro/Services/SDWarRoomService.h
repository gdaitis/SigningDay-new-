//
//  SDWarRoomService.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/21/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

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
                          pageIndex:(NSInteger)pageIndex
                           pageSize:(NSInteger)pageSize
                    completionBlock:(void (^)(NSInteger totalCount))completionBlock
                       failureBlock:(void (^)(void))failureBlock;
@end
