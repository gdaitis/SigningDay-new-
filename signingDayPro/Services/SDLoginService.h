//
//  SDLoginService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDProfileService.h"

extern NSString * const kSDLoginServiceUserDidLogoutNotification;

@interface SDLoginService : NSObject

+ (void)registerNewUserWithType:(SDUserType)userType
                       username:(NSString *)username
                       password:(NSString *)password
                          email:(NSString *)email
                    parentEmail:(NSString *)parentEmail
                 birthdayString:(NSString *)birthdayString
                  parentConsent:(BOOL)parentConsent
                   successBlock:(void (^)(void))successBlock
                   failureBlock:(void (^)(void))failureBlock;
+ (void)claimUserForUserIdentifier:(NSNumber *)identifier
                             email:(NSString *)email
                             phone:(NSString *)phone
                             image:(UIImage *)image
                      successBlock:(void (^)(void))successBlock
                      failureBlock:(void (^)(void))failureBlock;
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password facebookToken:(NSString *)facebookToken successBlock:(void (^)(void))successBlock failBlock:(void (^)(void))failBlock;
+ (void)logoutWithSuccessBlock:(void (^)(void))successBlock
                  failureBlock:(void (^)(void))failureBlock;
+ (void)cleanUpUserSession;

@end
