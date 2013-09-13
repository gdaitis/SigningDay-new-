//
//  SDProfileService.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/6/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    SDUserTypePlayer = 1,
    SDUserTypeTeam = 2,
    SDUserTypeCoach = 3,
    SDUserTypeHighSchool = 4,
    SDUserTypeMember = 5
} SDUserType;

@class User;

@interface SDProfileService : NSObject

+ (void)getProfileInfoForUser:(User *)theUser
              completionBlock:(void (^)(void))completionBlock
                 failureBlock:(void (^)(void))failureBlock;
+ (void)getProfileInfoForUserIdentifier:(NSNumber *)identifier
                        completionBlock:(void (^)(void))completionBlock
                           failureBlock:(void (^)(void))failureBlock;
+ (void)postNewProfileFieldsForUserWithIdentifier:(NSNumber *)identifier
                                             name:(NSString *)name
                                              bio:(NSString *)bio
                                  completionBlock:(void (^)(void))completionBlock
                                     failureBlock:(void (^)(void))failureBlock;
+ (void)uploadAvatar:(UIImage *)avatar
   forUserIdentifier:(NSNumber *)identifier
     completionBlock:(void (^)(void))completionBlock;
+ (void)getAvatarImageFromFacebookAndSendItToServerForUserIdentifier:(NSNumber *)identifier
                                                   completionHandler:(void (^)(void))completionHandler;
+ (void)deleteAvatar;
+ (void)updateLoggedInUserWithCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock;
+ (void)test;

@end
