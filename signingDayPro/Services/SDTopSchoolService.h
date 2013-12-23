//
//  SDTopSchoolService.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface SDTopSchoolService : NSObject

+ (void)getTopSchoolsForUser:(User *)user
             completionBlock:(void (^)(void))completionBlock
                failureBlock:(void (^)(void))failureBlock;
+ (void)saveTopSchoolsFromString:(NSString *)offersString
                 completionBlock:(void (^)(void))completionBlock
                    failureBlock:(void (^)(void))failureBlock;
@end
