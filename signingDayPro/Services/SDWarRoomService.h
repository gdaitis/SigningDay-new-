//
//  SDWarRoomService.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/21/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDWarRoomService : NSObject

+ (void)getWarRoomsWithCompletionBlock:(void (^)(void))completionBlock
                          failureBlock:(void (^)(void))failureBlock;


@end
