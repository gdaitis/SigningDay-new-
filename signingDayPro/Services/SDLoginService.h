//
//  SDLoginService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSDLoginServiceUserDidLogoutNotification;

@interface SDLoginService : NSObject

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password facebookToken:(NSString *)facebookToken successBlock:(void (^)(void))successBlock failBlock:(void (^)(void))failBlock;
+ (void)logoutWithSuccessBlock:(void (^)(void))successBlock
                  failureBlock:(void (^)(void))failureBlock;
+ (void)cleanUpUserSession;

@end
