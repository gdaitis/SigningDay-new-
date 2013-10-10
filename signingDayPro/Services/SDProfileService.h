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
    SDUserTypeMember = 5,
    SDUserTypeOrganization = 6,
    SDUserTypeNFLPA = 7
} SDUserType;

typedef enum {
    SDGalleryTypePhotos = 1,
    SDGalleryTypeVideos = 2
} SDGalleryType;

@class User;

@interface SDProfileService : NSObject

+ (void)getCoachingStaffForTeamWithIdentifier:(NSString *)teamIdentifier
                              completionBlock:(void (^)(void))completionBlock
                                 failureBlock:(void (^)(void))failureBlock;
+ (void)getRostersForHighSchoolWithIdentifier:(NSString *)highSchoolIdentifier
                              completionBlock:(void (^)(void))completionBlock
                                 failureBlock:(void (^)(void))failureBlock;
+ (void)getCommitsForTeamWithIdentifier:(NSString *)teamIdentifier
                          andYearString:(NSString *)yearString
                        completionBlock:(void (^)(void))completionBlock
                           failureBlock:(void (^)(void))failureBlock;

+ (void)getKeyAttributesForUserWithIdentifier:(NSString *)userIdentifier
                              completionBlock:(void (^)(NSArray *results))completionBlock
                                 failureBlock:(void (^)(void))failureBlock;
+ (void)getBasicProfileInfoForUserIdentifier:(NSNumber *)identifier
                             completionBlock:(void (^)(void))completionBlock
                                failureBlock:(void (^)(void))failureBlock;
+ (void)getProfileInfoForUser:(User *)theUser
              completionBlock:(void (^)(void))completionBlock
                 failureBlock:(void (^)(void))failureBlock;
+ (void)getPhotosForUser:(User *)user
         completionBlock:(void (^)(void))completionBlock
            failureBlock:(void (^)(void))failureBlock;
+ (void)getVideosForUser:(User *)user
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

@end
