//
//  SDProfileService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/6/12.
//
//

#import "SDProfileService.h"
#import "SDAPIClient.h"
#import "User.h"
#import "Master.h"
#import "AFHTTPRequestOperation.h"
#import "STKeychain.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+fixOrientation.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"
#import "SDErrorService.h"
#import "NSString+HTML.h"
#import "Player.h"
#import "Offer.h"
#import "Coach.h"
#import "Team.h"
#import "Member.h"
#import "HighSchool.h"
#import "NSDictionary+NullConverver.h"
#import "NSObject+MasterUserMethods.h"
#import "MediaItem.h"
#import "MediaGallery.h"
#import "SDUtils.h"
#import "State.h"
#import "NFLPA.h"

@interface SDProfileService ()

+ (void)uploadAvatarForUserIdentifier:(NSNumber *)identifier
                           verbMethod:(NSString *)verbMethod
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
                      completionBlock:(void (^)(void))completionBlock;

@end

@implementation SDProfileService


+ (void)getCoachingStaffForTeamWithIdentifier:(NSString *)teamIdentifier
                              completionBlock:(void (^)(void))completionBlock
                                 failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/TeamsService.asmx/GetCoachingStaffForMobile", kSDBaseSigningDayURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"json" forHTTPHeaderField:@"Data-Type"];
    NSString *body = [NSString stringWithFormat:@"{teamId:%@}",teamIdentifier];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:nil] dictionaryByReplacingNullsWithStrings];
        NSDictionary *dictionary = [[JSON valueForKey:@"d"] dictionaryByReplacingNullsWithStrings];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        User *teamUser = [User MR_findFirstByAttribute:@"identifier"
                                             withValue:[NSNumber numberWithInt:[teamIdentifier intValue]]
                                             inContext:context];
        teamUser.theTeam.headCoaches = nil;
        
        NSArray *headcoachesArray = [dictionary valueForKey:@"Level1"];
        for (NSDictionary *playerDictionary in headcoachesArray) {
            NSDictionary *dictionary = [playerDictionary dictionaryByReplacingNullsWithStrings];
            [self saveCoachFromDictionary:dictionary withLevel:1 andTeam:teamUser.theTeam forCoach:nil inContext:context];
        }
        
        NSArray *subcoachesArray = [dictionary valueForKey:@"Level2"];
        for (NSDictionary *subCoachDictionary in subcoachesArray) {
            NSDictionary *dictionary = [subCoachDictionary dictionaryByReplacingNullsWithStrings];
            [self saveCoachFromDictionary:dictionary withLevel:2 andTeam:teamUser.theTeam forCoach:nil inContext:context];
        }
        
        [context MR_saveOnlySelfAndWait];
        completionBlock();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    [operation start];
}

+ (void)saveCoachFromDictionary:(NSDictionary *)dictionary withLevel:(int)level andTeam:(Team *)team forCoach:(Coach *)coach inContext:(NSManagedObjectContext *)context
{
    dictionary = [dictionary dictionaryByReplacingNullsWithStrings];
    NSNumber *coachIdentifier = [NSNumber numberWithInt:[[dictionary valueForKey:@"UserId"] intValue]];
    User *coachUser = [User MR_findFirstByAttribute:@"identifier"
                                          withValue:coachIdentifier
                                          inContext:context];
    //    NSString *name = [dictionary valueForKey:@"DisplayName"] ? [dictionary valueForKey:@"DisplayName"] : [dictionary valueForKey:@"Name"];
    //    User *coachUser = [User MR_findFirstByAttribute:@"name"
    //                                          withValue:name
    //                                          inContext:context];
    
    if (!coachUser) {
        coachUser = [User MR_createInContext:context];
        coachUser.identifier = coachIdentifier;
    }
    if (!coachUser.theCoach)
        coachUser.theCoach = [Coach MR_createInContext:context];
    coachUser.name = [dictionary valueForKey:@"DisplayName"] ? [dictionary valueForKey:@"DisplayName"] : [dictionary valueForKey:@"Name"];
    coachUser.accountVerified = [NSNumber numberWithInt:[[dictionary valueForKey:@"IsVerified"] intValue]];
    coachUser.avatarUrl = [dictionary valueForKey:@"AvatarUrl"];
    coachUser.theCoach.position = [dictionary valueForKey:@"Position"];
    coachUser.theCoach.coachLevel = [NSNumber numberWithInt:level];
    coachUser.userTypeId = [NSNumber numberWithInt:SDUserTypeCoach];
    
    [team addHeadCoachesObject:coachUser.theCoach];
    if (coach) {
        [coach addSubCoachesObject:coachUser.theCoach];
    }
    
    if ([dictionary valueForKey:@"ChildCoaches"]) {
        NSArray *childCoaches = [dictionary valueForKey:@"ChildCoaches"];
        for (NSDictionary *coachDictionary in childCoaches) {
            [self saveCoachFromDictionary:coachDictionary withLevel:3 andTeam:team forCoach:coachUser.theCoach inContext:context];
        }
    }
}

+ (void)getRostersForHighSchoolWithIdentifier:(NSString *)highSchoolIdentifier
                              completionBlock:(void (^)(void))completionBlock
                                 failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/HighSchoolService.asmx/GetHighSchoolRosterForMobile", kSDBaseSigningDayURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"json" forHTTPHeaderField:@"Data-Type"];
    NSString *body = [NSString stringWithFormat:@"{highSchoolId:%@}",highSchoolIdentifier];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:nil] dictionaryByReplacingNullsWithStrings];
        NSArray *userInfoArray = [JSON valueForKey:@"d"];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        User *highSchoolUser = [User MR_findFirstByAttribute:@"identifier"
                                                   withValue:[NSNumber numberWithInt:[highSchoolIdentifier intValue]]
                                                   inContext:context];
        highSchoolUser.theHighSchool.rosters = nil;
        
        for (NSDictionary *userDictionary in userInfoArray) {
            
            NSDictionary *dictionary = [userDictionary dictionaryByReplacingNullsWithStrings];
            
            NSNumber *identifier = [NSNumber numberWithInt:[[dictionary valueForKey:@"UserId"] intValue]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
            User *user = [User MR_findFirstWithPredicate:predicate inContext:context];
            if (!user) {
                user = [User MR_createInContext:context];
                user.identifier = identifier;
            }
            user.name = [dictionary valueForKey:@"DisplayName"];
            user.avatarUrl = [dictionary valueForKey:@"AvatarUrl"];
            user.userTypeId = [NSNumber numberWithInt:SDUserTypePlayer];
            
            if (!user.thePlayer)
                user.thePlayer = [Player MR_createInContext:context];
            
            user.thePlayer.userClass = [NSString stringWithFormat:@"%d", [[dictionary valueForKey:@"Class"] intValue]];
            user.thePlayer.position = [dictionary valueForKey:@"Position"];
            user.thePlayer.baseScore = [NSNumber numberWithFloat:[[dictionary valueForKey:@"BaseScore"] floatValue]];
            user.thePlayer.starsCount = [NSNumber numberWithInt:[[dictionary valueForKey:@"PlayerStars"] intValue]];
            user.thePlayer.has150Badge = [NSNumber numberWithBool:[[dictionary valueForKey:@"Has150Badge"] boolValue]];
            user.thePlayer.hasWatchListBadge = [NSNumber numberWithBool:[[dictionary valueForKey:@"HasWatchListBadge"] boolValue]];
            user.thePlayer.rosterOf = highSchoolUser.theHighSchool;
            user.thePlayer.highSchool = highSchoolUser.theHighSchool;
        }
        
        [context MR_saveOnlySelfAndWait];
        completionBlock();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    [operation start];
}

+ (void)getCommitsForTeamWithIdentifier:(NSString *)teamIdentifier
                          andYearString:(NSString *)yearString
                        completionBlock:(void (^)(void))completionBlock
                           failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/TeamsService.asmx/GetTeamCommitsForMobile", kSDBaseSigningDayURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"json" forHTTPHeaderField:@"Data-Type"];
    NSString *body = [NSString stringWithFormat:@"{teamId:%@, year:%@}",teamIdentifier,yearString];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:nil] dictionaryByReplacingNullsWithStrings];
        NSArray *userInfoArray = [JSON valueForKey:@"d"];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        User *teamUser = [User MR_findFirstByAttribute:@"identifier"
                                             withValue:[NSNumber numberWithInt:[teamIdentifier intValue]]
                                             inContext:context];
        teamUser.theTeam.offers = nil;
        
        for (NSDictionary *playerDictionary in userInfoArray) {
            
            NSDictionary *dictionary = [playerDictionary dictionaryByReplacingNullsWithStrings];
            NSNumber *identifier = [NSNumber numberWithInt:[[dictionary valueForKey:@"UserId"] intValue]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
            User *user = [User MR_findFirstWithPredicate:predicate inContext:context];
            if (!user) {
                user = [User MR_createInContext:context];
                user.identifier = identifier;
            }
            user.name = [dictionary valueForKey:@"DisplayName"];
            user.avatarUrl = [dictionary valueForKey:@"AvatarUrl"];
            user.userTypeId = [NSNumber numberWithInt:SDUserTypePlayer];
            
            
            NSNumber *highSchoolNumber = [NSNumber numberWithInt:[[dictionary valueForKey:@"HighSchoolId"] intValue]];
            NSPredicate *highSchoolPredicate = [NSPredicate predicateWithFormat:@"identifier == %@", highSchoolNumber];
            User *highSchoolUser = [User MR_findFirstWithPredicate:highSchoolPredicate inContext:context];
            
            if (!highSchoolUser) {
                highSchoolUser = [User MR_createInContext:context];
                highSchoolUser.identifier = highSchoolNumber;
            }
            
            if (!highSchoolUser.theHighSchool)
                highSchoolUser.theHighSchool = [HighSchool MR_createInContext:context];
            highSchoolUser.theHighSchool.city = [dictionary valueForKey:@"HighSchoolCity"];
            highSchoolUser.name = [dictionary valueForKey:@"HighSchoolName"];
            
            
            
            NSString *code = [dictionary valueForKey:@"HighSchoolState"];
            State *state = [State MR_findFirstByAttribute:@"code"
                                                withValue:code
                                                inContext:context];
            if (!state) {
                state = [State MR_createInContext:context];
                state.code = code;
            }
            highSchoolUser.state = state;
            user.theHighSchool.stateCode = code;
            
            if (!user.thePlayer)
                user.thePlayer = [Player MR_createInContext:context];
            
            user.thePlayer.userClass = [NSString stringWithFormat:@"%d", [[dictionary valueForKey:@"Class"] intValue]];
            user.thePlayer.position = [dictionary valueForKey:@"Position"];
            user.thePlayer.baseScore = [dictionary valueForKey:@"BaseScore"] != [NSNull null] ? [NSNumber numberWithFloat:[[dictionary valueForKey:@"BaseScore"] floatValue]] : nil;
            user.thePlayer.starsCount = [NSNumber numberWithInt:[[dictionary valueForKey:@"PlayerStars"] intValue]];
            user.thePlayer.has150Badge = [NSNumber numberWithBool:[[dictionary valueForKey:@"Has150Badge"] boolValue]];
            user.thePlayer.hasWatchListBadge = [NSNumber numberWithBool:[[dictionary valueForKey:@"HasWatchListBadge"] boolValue]];
            user.thePlayer.highSchool = highSchoolUser.theHighSchool;
            
            Offer *offer = [Offer MR_createInContext:context];
            offer.playerCommited = [NSNumber numberWithBool:YES];
            offer.player = user.thePlayer;
            offer.team = teamUser.theTeam;
        }
        
        [context MR_saveOnlySelfAndWait];
        completionBlock();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    [operation start];
}


+ (void)getKeyAttributesForUserWithIdentifier:(NSString *)userIdentifier
                              completionBlock:(void (^)(NSArray *results))completionBlock
                                 failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/PlayerService.asmx/GetKeyAttributesForMobile", kSDBaseSigningDayURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"json" forHTTPHeaderField:@"Data-Type"];
    NSString *body = [NSString stringWithFormat:@"{playerId:%@}",userIdentifier];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:nil] dictionaryByReplacingNullsWithStrings];
        NSArray *userInfoArray = [JSON valueForKey:@"d"];
        
        completionBlock(userInfoArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    [operation start];
}



+ (void)getProfileInfoForUser:(User *)theUser
              completionBlock:(void (^)(void))completionBlock
                 failureBlock:(void (^)(void))failureBlock
{
    [[SDAPIClient sharedClient] getPath:@"sd/profile.json"
                             parameters:@{@"userId": [NSString stringWithFormat:@"%d", [theUser.identifier integerValue]]}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSDictionary *userDictionary = [[JSON valueForKey:@"Profile"] dictionaryByReplacingNullsWithStrings];
                                    
                                    NSNumber *identifier = [NSNumber numberWithInt:[[userDictionary valueForKey:@"UserId"] intValue]];
                                    NSString *username = [userDictionary valueForKey:@"UserName"];
                                    NSManagedObjectContext *userContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                    User *user = [User MR_findFirstByAttribute:@"identifier"
                                                                     withValue:identifier
                                                                     inContext:userContext];
                                    if (!user) {
                                        user = [User MR_findFirstByAttribute:@"username"
                                                                   withValue:username
                                                                   inContext:userContext];
                                    }
                                    if (!user) {
                                        user = [User MR_createInContext:userContext];
                                        user.identifier = identifier;
                                    }
                                    user.username = username;
                                    user.name = [userDictionary valueForKey:@"DisplayName"];
                                    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
                                    user.numberOfFollowers = [NSNumber numberWithInt:[[userDictionary valueForKey:@"FollowersCount"] intValue]];
                                    user.numberOfFollowing = [NSNumber numberWithInt:[[userDictionary valueForKey:@"FollowingCount"] intValue]];
                                    user.allowBuzzMessage = [NSNumber numberWithBool:[[userDictionary valueForKey:@"AllowBuzzMessage"] boolValue]];
                                    user.allowPrivateMessage = [NSNumber numberWithBool:[[userDictionary valueForKey:@"AllowPrivateMessage"] boolValue]];
                                    
                                    NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:masterUsername inContext:userContext];
                                    user.followedBy = ([[userDictionary valueForKey:@"IsFollowing"] boolValue]) ? master : nil;
                                    
                                    NSNumber *photoGalleryIdentifier = [NSNumber numberWithInteger:[[userDictionary valueForKey:@"PhotoGalleryId"] integerValue]];
                                    MediaGallery *photoGallery = [MediaGallery MR_findFirstByAttribute:@"identifier"
                                                                                             withValue:photoGalleryIdentifier
                                                                                             inContext:userContext];
                                    if (!photoGallery) {
                                        photoGallery = [MediaGallery MR_createInContext:userContext];
                                        photoGallery.identifier = photoGalleryIdentifier;
                                    }
                                    photoGallery.galleryType = [NSNumber numberWithInteger:SDGalleryTypePhotos];
                                    photoGallery.user = user;
                                    
                                    NSNumber *videoGalleryIdentifier = [NSNumber numberWithInteger:[[userDictionary valueForKey:@"VideoGalleryId"] integerValue]];
                                    MediaGallery *videoGallery = [MediaGallery MR_findFirstByAttribute:@"identifier"
                                                                                             withValue:videoGalleryIdentifier
                                                                                             inContext:userContext];
                                    if (!videoGallery) {
                                        videoGallery = [MediaGallery MR_createInContext:userContext];
                                        videoGallery.identifier = videoGalleryIdentifier;
                                    }
                                    videoGallery.galleryType = [NSNumber numberWithInteger:SDGalleryTypeVideos];
                                    videoGallery.user = user;
                                    
                                    if ([userDictionary valueForKey:@"DerivedUser"]) {
                                        if ([[userDictionary valueForKey:@"DerivedUser"] isKindOfClass:[NSDictionary class]]) {
                                            
                                            NSDictionary *derivedUserDictionary = [[userDictionary valueForKey:@"DerivedUser"] dictionaryByReplacingNullsWithStrings];
                                            
                                            SDUserType userTypeId = [[userDictionary valueForKey:@"UserTypeId"] intValue];
                                            user.userTypeId = [NSNumber numberWithInt:userTypeId];
                                            
                                            switch (userTypeId) {
                                                case SDUserTypePlayer: {
                                                    if (!user.thePlayer)
                                                        user.thePlayer = [Player MR_createInContext:userContext];
                                                    user.thePlayer.positionRanking = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"PositionRanking"] intValue]];
                                                    user.thePlayer.stateRanking = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"StateRanking"] intValue]];
                                                    user.thePlayer.height = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"Height"] intValue]];
                                                    user.thePlayer.weight = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"Weight"] intValue]];
                                                    user.thePlayer.userClass = [NSString stringWithFormat:@"%d", [[derivedUserDictionary valueForKey:@"Class"] intValue]];
                                                    user.thePlayer.position = [derivedUserDictionary valueForKey:@"Position"];
                                                    user.thePlayer.baseScore = [NSNumber numberWithFloat:[[derivedUserDictionary valueForKey:@"BaseScore"] floatValue]];
                                                    user.thePlayer.nationalRanking = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"NationalRanking"] intValue]];
                                                    user.thePlayer.starsCount = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"StarsCount"] intValue]];
                                                    
                                                    if ([[derivedUserDictionary valueForKey:@"HighSchool"] isKindOfClass:[NSDictionary class]]) {
                                                        NSDictionary *highSchoolDictionary = [[derivedUserDictionary valueForKey:@"HighSchool"] dictionaryByReplacingNullsWithStrings];
                                                        
                                                        if ([highSchoolDictionary valueForKey:@"HighSchoolId"]) {
                                                            NSNumber *highSchoolIdentifier = [NSNumber numberWithInt:[[highSchoolDictionary valueForKey:@"HighSchoolId"] intValue]];
                                                            User *highSchoolUser = [User MR_findFirstByAttribute:@"identifier"
                                                                                                       withValue:highSchoolIdentifier
                                                                                                       inContext:userContext];
                                                            if (!highSchoolUser) {
                                                                highSchoolUser = [User MR_createInContext:userContext];
                                                                highSchoolUser.identifier = highSchoolIdentifier;
                                                            }
                                                            highSchoolUser.name = [highSchoolDictionary valueForKey:@"Name"];
                                                            highSchoolUser.avatarUrl = [highSchoolDictionary valueForKey:@"AvatarUrl"];
                                                            if (!highSchoolUser.theHighSchool)
                                                                highSchoolUser.theHighSchool = [HighSchool MR_createInContext:userContext];
                                                            highSchoolUser.theHighSchool.mascot = [highSchoolDictionary valueForKey:@"Mascot"];
                                                            highSchoolUser.theHighSchool.headCoachName = [highSchoolDictionary valueForKey:@"HeadCoach"];
                                                            highSchoolUser.theHighSchool.address = [highSchoolDictionary valueForKey:@"Address"];
                                                            highSchoolUser.userTypeId = [NSNumber numberWithInt:SDUserTypeHighSchool];
                                                            
                                                            user.thePlayer.highSchool = highSchoolUser.theHighSchool;
                                                            
                                                            NSString *code = [highSchoolDictionary valueForKey:@"StateCode"];
                                                            State *state = [State MR_findFirstByAttribute:@"code"
                                                                                                withValue:code
                                                                                                inContext:userContext];
                                                            if (!state) {
                                                                state = [State MR_createInContext:userContext];
                                                                state.code = code;
                                                            }
                                                            highSchoolUser.state = state;
                                                        }
                                                    }
                                                }
                                                    break;
                                                    
                                                case SDUserTypeTeam: {
                                                    if (!user.theTeam)
                                                        user.theTeam = [Team MR_createInContext:userContext];
                                                    NSDictionary *conferenceDictionary = [derivedUserDictionary valueForKey:@"Conference"];
                                                    user.theTeam.conferenceName = [conferenceDictionary valueForKey:@"Name"];
                                                    user.theTeam.conferenceLogoUrl = [conferenceDictionary valueForKey:@"LogoUrl"];
                                                    user.theTeam.conferenceLogoUrlBlack = [conferenceDictionary valueForKey:@"LogoUrlBlack"];
                                                    user.theTeam.locationExtended = [derivedUserDictionary valueForKey:@"Location"];
                                                    user.theTeam.universityName = [derivedUserDictionary valueForKey:@"UniversityName"];
                                                    user.theTeam.conferenceRankingString = [derivedUserDictionary valueForKey:@"ConferenceRanking"];
                                                    user.theTeam.nationalRankingString = [derivedUserDictionary valueForKey:@"NationalRanking"];
                                                    
                                                    NSDictionary *coachDictionary = [derivedUserDictionary valueForKey:@"Coach"];
                                                    NSNumber *coachIdentifier = [NSNumber numberWithInt:[[coachDictionary valueForKey:@"CoachId"] intValue]];
                                                    User *coachUser = [User MR_findFirstByAttribute:@"identifier"
                                                                                          withValue:coachIdentifier
                                                                                          inContext:userContext];
                                                    if (!coachUser) {
                                                        coachUser = [User MR_createInContext:userContext];
                                                        coachUser.identifier = coachIdentifier;
                                                    }
                                                    if (!coachUser.theCoach)
                                                        coachUser.theCoach = [Coach MR_createInContext:userContext];
                                                    coachUser.name = [coachDictionary valueForKey:@"CoachName"];
                                                    coachUser.theCoach.location = [coachDictionary valueForKey:@"Location"];
                                                    coachUser.theCoach.position = [coachDictionary valueForKey:@"Position"];
                                                    coachUser.theCoach.coachLevel = [NSNumber numberWithInt:1]; //we are getting headcoach here
                                                    coachUser.theCoach.team = user.theTeam;
                                                    coachUser.userTypeId = [NSNumber numberWithInt:SDUserTypeCoach];
                                                }
                                                    break;
                                                    
                                                case SDUserTypeCoach: {
                                                    if (!user.theCoach)
                                                        user.theCoach = [Coach MR_createInContext:userContext];
                                                    user.theCoach.location = [derivedUserDictionary valueForKey:@"Location"];
                                                    user.theCoach.position = [derivedUserDictionary valueForKey:@"Position"];
#warning set "team" only for head coach
                                                    NSDictionary *teamDictionary = [derivedUserDictionary valueForKey:@"Team"];
                                                    NSNumber *teamIdentifier = [NSNumber numberWithInt:[[teamDictionary valueForKey:@"TeamId"] intValue]];
                                                    User *teamUser = [User MR_findFirstByAttribute:@"identifier"
                                                                                         withValue:teamIdentifier
                                                                                         inContext:userContext];
                                                    if (!teamUser) {
                                                        teamUser = [User MR_createInContext:userContext];
                                                        teamUser.identifier = teamIdentifier;
                                                    }
                                                    teamUser.avatarUrl = [teamDictionary valueForKey:@"AvatarUrl"];
                                                    if (!teamUser.theTeam)
                                                        teamUser.theTeam = [Team MR_createInContext:userContext];
                                                    NSDictionary *conferenceDictionary = [teamDictionary valueForKey:@"Conference"];
                                                    teamUser.theTeam.conferenceName = [conferenceDictionary valueForKey:@"Name"];
                                                    teamUser.theTeam.conferenceLogoUrl = [conferenceDictionary valueForKey:@"LogoUrl"];
                                                    teamUser.theTeam.conferenceLogoUrlBlack = [conferenceDictionary valueForKey:@"LogoUrlBlack"];
                                                    teamUser.theTeam.location = [teamDictionary valueForKey:@"Location"];
                                                    teamUser.theTeam.universityName = [teamDictionary valueForKey:@"UniversityName"];
                                                    teamUser.theTeam.conferenceRankingString = [teamDictionary valueForKey:@"ConferenceRanking"];
                                                    teamUser.theTeam.nationalRankingString = [teamDictionary valueForKey:@"NationalRanking"];
                                                    teamUser.userTypeId = [NSNumber numberWithInt:SDUserTypeTeam];
                                                    
                                                    user.theCoach.team = teamUser.theTeam;
                                                }
                                                    break;
                                                    
                                                case SDUserTypeHighSchool: {
                                                    if (!user.theHighSchool)
                                                        user.theHighSchool = [HighSchool MR_createInContext:userContext];
                                                    user.theHighSchool.mascot = [derivedUserDictionary valueForKey:@"Mascot"];
                                                    user.theHighSchool.headCoachName = [derivedUserDictionary valueForKey:@"HeadCoach"];
                                                    user.theHighSchool.address = [derivedUserDictionary valueForKey:@"Address"];
                                                }
                                                    break;
                                                    
                                                case SDUserTypeMember: {
                                                    if (!user.theMember)
                                                        user.theMember = [Member MR_createInContext:userContext];
                                                    user.theMember.uploadsCount = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"UploadsCount"] intValue]];
                                                    user.theMember.postsCount = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"PostsCount"] intValue]];
                                                    
                                                    NSString *memmberSinceString = [derivedUserDictionary valueForKey:@"MemberSince"];
                                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                    dateFormatter.dateFormat = @"MMMM dd, yyyy";
                                                    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                                    dateFormatter.locale = usLocale;
                                                    NSDate *memberSinceDate = [dateFormatter dateFromString:memmberSinceString];
                                                    user.theMember.memberSince = memberSinceDate;
                                                    
                                                    NSDictionary *teamDictionary = [derivedUserDictionary valueForKey:@"FavoriteTeam"];
                                                    if ([[teamDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                                                        if ([teamDictionary objectForKey:@"TeamId"]) {
                                                            NSNumber *teamIdentifier = [NSNumber numberWithInt:[[teamDictionary valueForKey:@"TeamId"] intValue]];
                                                            User *teamUser = [User MR_findFirstByAttribute:@"identifier"
                                                                                                 withValue:teamIdentifier
                                                                                                 inContext:userContext];
                                                            if (!teamUser) {
                                                                teamUser = [User MR_createInContext:userContext];
                                                                teamUser.identifier = teamIdentifier;
                                                            }
                                                            teamUser.avatarUrl = [teamDictionary valueForKey:@"AvatarUrl"];
                                                            if (!teamUser.theTeam)
                                                                teamUser.theTeam = [Team MR_createInContext:userContext];
                                                            NSDictionary *conferenceDictionary = [teamDictionary valueForKey:@"Conference"];
                                                            teamUser.theTeam.conferenceName = [conferenceDictionary valueForKey:@"Name"];
                                                            teamUser.theTeam.conferenceLogoUrl = [conferenceDictionary valueForKey:@"LogoUrl"];
                                                            teamUser.theTeam.conferenceLogoUrlBlack = [conferenceDictionary valueForKey:@"LogoUrlBlack"];
                                                            teamUser.theTeam.location = [teamDictionary valueForKey:@"Location"];
                                                            teamUser.theTeam.universityName = [teamDictionary valueForKey:@"UniversityName"];
                                                            teamUser.theTeam.conferenceRankingString = [teamDictionary valueForKey:@"ConferenceRanking"];
                                                            teamUser.theTeam.nationalRankingString = [teamDictionary valueForKey:@"NationalRanking"];
                                                            teamUser.userTypeId = [NSNumber numberWithInt:SDUserTypeTeam];
                                                            
                                                            user.theMember.favoriteTeam = teamUser.theTeam;
                                                        }
                                                    }
                                                }
                                                    break;
                                                    
                                                case SDUserTypeNFLPA: {
                                                    if (!user.theNFLPA)
                                                        user.theNFLPA = [NFLPA MR_createInContext:userContext];
                                                    user.theNFLPA.collegeName = [derivedUserDictionary valueForKey:@"College"];
                                                    user.theNFLPA.nflpaAvatarUrl = [derivedUserDictionary valueForKey:@"NFLPAAvatarUrl"];
                                                    user.theNFLPA.position = [derivedUserDictionary valueForKey:@"Position"];
                                                    user.theNFLPA.teamName = [derivedUserDictionary valueForKey:@"Team"];
                                                    user.theNFLPA.websiteTitle = [derivedUserDictionary valueForKey:@"Website"];
                                                    user.theNFLPA.websiteUrl = [derivedUserDictionary valueForKey:@"WebsiteURL"];
                                                    user.theNFLPA.yearsPro = [NSNumber numberWithInt:[[derivedUserDictionary valueForKey:@"YearsPro"] intValue]];
                                                }
                                                    break;
                                                    
                                                default:
                                                    break;
                                            }
                                        }
                                    }
                                    [userContext MR_saveOnlySelfAndWait];
                                    
                                    if (completionBlock)
                                        completionBlock();
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getBasicProfileInfoForUserIdentifier:(NSNumber *)identifier
                             completionBlock:(void (^)(void))completionBlock
                                failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"users/%d.json", [identifier integerValue]];
    [[SDAPIClient sharedClient] getPath:path
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
                                    User *user = [User MR_findFirstWithPredicate:predicate inContext:context];
                                    if (!user) {
                                        user = [User MR_createInContext:context];
                                        user.identifier = identifier;
                                    }
                                    NSDictionary *userDictionary = [[JSON valueForKey:@"User"] dictionaryByReplacingNullsWithStrings];
                                    
                                    user.username = [userDictionary valueForKey:@"Username"];
                                    user.name = [userDictionary valueForKey:@"DisplayName"];
                                    user.bio = [[userDictionary valueForKey:@"Bio"] stringByConvertingHTMLToPlainText];
                                    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
                                    
                                    [context MR_saveToPersistentStoreAndWait];
                                    if (completionBlock)
                                        completionBlock();
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [SDErrorService handleError:error withOperation:operation];
                                    if (failureBlock)
                                        failureBlock();
                                }];
    
}

+ (void)getPhotosForUser:(User *)user
         completionBlock:(void (^)(void))completionBlock
            failureBlock:(void (^)(void))failureBlock
{
    [self getMediaGalleryItemsForUser:user
                          galleryType:SDGalleryTypePhotos
                      completionBlock:completionBlock
                         failureBlock:failureBlock];
}

+ (void)getVideosForUser:(User *)user
         completionBlock:(void (^)(void))completionBlock
            failureBlock:(void (^)(void))failureBlock
{
    [self getMediaGalleryItemsForUser:user
                          galleryType:SDGalleryTypeVideos
                      completionBlock:completionBlock
                         failureBlock:failureBlock];
}

+ (void)getMediaGalleryItemsForUser:(User *)user
                        galleryType:(SDGalleryType)galleryType
                    completionBlock:(void (^)(void))completionBlock
                       failureBlock:(void (^)(void))failureBlock
{
    NSPredicate *mediaGalleryPredicate = [NSPredicate predicateWithFormat:@"user == %@ AND galleryType == %d", user, galleryType];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    MediaGallery *mediaGallery = [MediaGallery MR_findFirstWithPredicate:mediaGalleryPredicate
                                                               inContext:context];
    NSString *mediaGalleryIdString = [NSString stringWithFormat:@"%d", [mediaGallery.identifier integerValue]];
    NSString *mediaGalleryTypeString = [NSString stringWithFormat:@"%d", galleryType];
    [[SDAPIClient sharedClient] getPath:@"sd/media.json"
                             parameters:@{@"MediaGalleryId": mediaGalleryIdString, @"MediaType": mediaGalleryTypeString, @"width": @400, @"height": @400}
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSArray *mediaListArray = [JSON valueForKey:@"MediaList"];
                                    for (__strong NSDictionary *mediaItemDictionary in mediaListArray) {
                                        mediaItemDictionary = [mediaItemDictionary dictionaryByReplacingNullsWithStrings];
                                        NSNumber *identifier = [NSNumber numberWithInteger:[[mediaItemDictionary valueForKey:@"Id"] integerValue]];
                                        MediaItem *mediaItem = [MediaItem MR_findFirstByAttribute:@"identifier"
                                                                                        withValue:identifier
                                                                                        inContext:context];
                                        if (!mediaItem) {
                                            mediaItem = [MediaItem MR_createInContext:context];
                                            mediaItem.identifier = identifier;
                                        }
                                        mediaItem.contentType = [mediaItemDictionary valueForKey:@"ContentType"];
                                        mediaItem.createdDate = [SDUtils dateFromString:[mediaItemDictionary valueForKey:@"CreatedDate"]];
                                        mediaItem.fileName = [mediaItemDictionary valueForKey:@"FileItem"];
                                        mediaItem.fileUrl = [mediaItemDictionary valueForKey:@"FileUrl"];
                                        mediaItem.thumbnailUrl = [[mediaItemDictionary valueForKey:@"ThumbnailUrl"] stringByReplacingOccurrencesOfString:@"400x400" withString:@"1000x1000"];
                                        
                                        mediaItem.title = [mediaItemDictionary valueForKey:@"Title"];
                                        mediaItem.mediaGallery = mediaGallery;
                                    }
                                    [context MR_saveOnlySelfAndWait];
                                    if (completionBlock) {
                                        completionBlock();
                                    }
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)getProfileInfoForUserIdentifier:(NSNumber *)identifier
                        completionBlock:(void (^)(void))completionBlock
                           failureBlock:(void (^)(void))failureBlock
{
    NSString *path = [NSString stringWithFormat:@"users/%d.json", [identifier integerValue]];
    [[SDAPIClient sharedClient] getPath:path
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
                                    NSNumber *identifier = master.identifier;
                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
                                    User *user = [User MR_findFirstWithPredicate:predicate inContext:context];
                                    if (!user) {
                                        user = [User MR_createInContext:context];
                                        user.identifier = identifier;
                                    }
                                    user.username = username;
                                    NSDictionary *userDictionary = [JSON valueForKey:@"User"];
                                    user.name = [userDictionary valueForKey:@"DisplayName"];
                                    user.bio = [[userDictionary valueForKey:@"Bio"] stringByConvertingHTMLToPlainText];
                                    user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
                                    
                                    [context MR_saveToPersistentStoreAndWait];
                                    
                                    NSString *followingPath = [NSString stringWithFormat:@"users/%d/following.json", [identifier integerValue]];
                                    [[SDAPIClient sharedClient] getPath:followingPath
                                                             parameters:nil
                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                    user.numberOfFollowing = [NSNumber numberWithInteger:[[JSON valueForKey:@"TotalCount"] integerValue]];
                                                                    NSLog(@"Following: %@", user.numberOfFollowing);
                                                                    
                                                                    [context MR_saveToPersistentStoreAndWait];
                                                                    
                                                                    NSString *followersPath = [NSString stringWithFormat:@"users/%d/followers.json", [identifier integerValue]];
                                                                    [[SDAPIClient sharedClient] getPath:followersPath
                                                                                             parameters:nil
                                                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                                                    
                                                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                                                    user.numberOfFollowers = [JSON valueForKey:@"TotalCount"];
                                                                                                    NSLog(@"Followers: %@", user.numberOfFollowers);
                                                                                                    
                                                                                                    [context MR_saveToPersistentStoreAndWait];
                                                                                                    
                                                                                                    NSString *photosCountPath = [[[NSString stringWithFormat:@"search.json?pagesize=1&filters=type::file||section::4||user::%d", [identifier integerValue]] stringByReplacingOccurrencesOfString:@":" withString:@"%3A"] stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];
                                                                                                    
                                                                                                    [[SDAPIClient sharedClient] getPath:photosCountPath
                                                                                                                             parameters:nil
                                                                                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                                                                                    
                                                                                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                                                                                    user.numberOfPhotos = [JSON valueForKey:@"TotalCount"];
                                                                                                                                    NSLog(@"Photos: %@", user.numberOfPhotos);
                                                                                                                                    
                                                                                                                                    [context MR_saveToPersistentStoreAndWait];
                                                                                                                                    
                                                                                                                                    NSString *videosCountPath = [[[NSString stringWithFormat:@"search.json?pagesize=1&filters=type::file||section::5||user::%d", [identifier integerValue]] stringByReplacingOccurrencesOfString:@":" withString:@"%3A"] stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];
                                                                                                                                    [[SDAPIClient sharedClient] getPath:videosCountPath
                                                                                                                                                             parameters:nil
                                                                                                                                                                success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                                                                                                                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                                                                                                                                                    
                                                                                                                                                                    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:context];
                                                                                                                                                                    user.numberOfVideos = [JSON valueForKey:@"TotalCount"];
                                                                                                                                                                    NSLog(@"Videos: %@", user.numberOfVideos);
                                                                                                                                                                    
                                                                                                                                                                    [context MR_saveToPersistentStoreAndWait];
                                                                                                                                                                    
                                                                                                                                                                    if (completionBlock)
                                                                                                                                                                        completionBlock();
                                                                                                                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                                                                                                                    if (failureBlock)
                                                                                                                                                                        failureBlock();
                                                                                                                                                                }];
                                                                                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                                                                                    if (failureBlock)
                                                                                                                                        failureBlock();
                                                                                                                                }];
                                                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                                                    if (failureBlock)
                                                                                                        failureBlock();
                                                                                                }];
                                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                    [SDErrorService handleError:error withOperation:operation];
                                                                    if (failureBlock)
                                                                        failureBlock();
                                                                }];
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [SDErrorService handleError:error withOperation:operation];
                                    if (failureBlock)
                                        failureBlock();
                                }];
}

+ (void)postNewProfileFieldsForUserWithIdentifier:(NSNumber *)identifier
                                             name:(NSString *)name
                                              bio:(NSString *)bio
                                  completionBlock:(void (^)(void))completionBlock
                                     failureBlock:(void (^)(void))failureBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kSDAPIBaseURLString]];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *apiKey = [STKeychain getPasswordForUsername:username andServiceName:@"SigningDayPro" error:nil];
    [httpClient setDefaultHeader:@"Rest-User-Token" value:apiKey];
    
    NSString *path = [NSString stringWithFormat:@"users/%d.json", [identifier integerValue]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (name) {
        [parameters setValue:name forKey:@"DisplayName"];
    }
    if (bio) {
        [parameters setValue:bio forKey:@"Bio"];
    }
    [httpClient setDefaultHeader:@"Rest-Method" value:@"PUT"];
    [httpClient postPath:path
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                     NSDictionary *userDictionary = [[JSON objectForKey:@"User"] dictionaryByReplacingNullsWithStrings];
                     NSString *displayName = [userDictionary valueForKey:@"DisplayName"];
                     NSString *bio = [[userDictionary valueForKey:@"Bio"] stringByConvertingHTMLToPlainText];
                     
                     NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                     
                     NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                     Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
                     User *user = [User MR_findFirstByAttribute:@"identifier" withValue:master.identifier inContext:context];
                     user.name = displayName;
                     user.bio = bio;
                     
                     [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
                     if (completionBlock)
                         completionBlock();
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [SDErrorService handleError:error withOperation:operation];
                     if (failureBlock)
                         failureBlock();
                 }];
}

+ (void)uploadAvatarForUserIdentifier:(NSNumber *)identifier
                           verbMethod:(NSString *)verbMethod
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
                      completionBlock:(void (^)(void))completionBlock
{
    
    NSString *path = [NSString stringWithFormat:@"users/%@/avatar.json", identifier];
    NSMutableURLRequest *request = [[SDAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                         path:path
                                                                                   parameters:nil
                                                                    constructingBodyWithBlock:block];
    [request addValue:@"PUT" forHTTPHeaderField:@"Rest-Method"];
    
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Uploading avatar";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        hud.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
        if (completionBlock)
            completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        NSLog(@"%@", operation.request.allHTTPHeaderFields);
        //        NSLog(@"%@", operation.responseString);
        if (error.code == -1011) {
            [self uploadAvatarForUserIdentifier:identifier
                                     verbMethod:@"POST"
                      constructingBodyWithBlock:block
                                completionBlock:completionBlock];
        } else {
            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            [SDErrorService handleError:error withOperation:operation];
        }
    }];
    [operation start];
}

+ (void)uploadAvatar:(UIImage *)avatar
   forUserIdentifier:(NSNumber *)identifier
     completionBlock:(void (^)(void))completionBlock
{
    [self uploadAvatarForUserIdentifier:identifier
                             verbMethod:@"POST"
              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                  
                  NSDate *todayDateObj = [NSDate date];
                  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                  [dateFormat setDateFormat:@"ddMMyyyyHHmmss"];
                  NSString *fileName = [NSString stringWithFormat:@"avatar%@.jpg", [dateFormat stringFromDate:todayDateObj]];
                  
                  UIImage *fixedImage = [avatar fixOrientation];
                  NSData *imageData = UIImageJPEGRepresentation(fixedImage, 1);
                  
                  [formData appendPartWithFileData:imageData
                                              name:@"avatar"
                                          fileName:fileName
                                          mimeType:@"image/jpeg"];
              }
                        completionBlock:completionBlock];
}

+ (void)getAvatarImageFromFacebookAndSendItToServerForUserIdentifier:(NSNumber *)identifier completionHandler:(void (^)(void))completionHandler
{
    NSString *baseUrlString = @"https://graph.facebook.com/";
    NSURL *baseUrl = [NSURL URLWithString:baseUrlString];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseUrl];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Connecting to Facebook";
    
    if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
        appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
    }
    [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (error) {
            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            [SDErrorService handleFacebookError];
        } else {
            NSLog(@"FB access token: %@", appDelegate.fbSession.accessTokenData.accessToken);
            if (status == FBSessionStateOpen) {
                NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
                master.facebookSharingOn = [NSNumber numberWithBool:YES];
                
                [context MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                }];
                
                NSString *fbToken = appDelegate.fbSession.accessTokenData.accessToken;
                NSString *path = [NSString stringWithFormat:@"me/picture/?access_token=%@", fbToken];
                
                [client getPath:path
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, NSData *avatarData) {
                            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                            [self uploadAvatarForUserIdentifier:identifier
                                                     verbMethod:@"PUT"
                                      constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                          NSDate *todayDateObj = [NSDate date];
                                          NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                          [dateFormat setDateFormat:@"ddMMyyyyHHmmss"];
                                          NSString *fileName = [NSString stringWithFormat:@"avatar%@.jpg", [dateFormat stringFromDate:todayDateObj]];
                                          
                                          [formData appendPartWithFileData:avatarData
                                                                      name:@"avatar"
                                                                  fileName:fileName
                                                                  mimeType:@"image/jpeg"];
                                      } completionBlock:^{
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler();
                                          });
                                      }];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                            [SDErrorService handleError:error withOperation:operation];
                        }];
            }
        }
    }];
}

+ (void)deleteAvatar
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kSDOldAPIBaseURLString]];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *apiKey = [STKeychain getPasswordForUsername:username andServiceName:@"SigningDayPro" error:nil];
    [httpClient setDefaultHeader:@"Rest-User-Token" value:apiKey];
    [httpClient setDefaultHeader:@"VERB" value:@"DELETE"];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
    NSNumber *identifier = master.identifier;;
    
    NSString *path = [NSString stringWithFormat:@"membership.ashx/users/%d/avatar", [identifier integerValue]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:path parameters:nil];
    
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Deleting avatar";
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Avatar deleted successfully");
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SDErrorService handleError:error withOperation:operation];
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    }];
    [operation start];
}



#pragma mark - user update

+ (void)updateLoggedInUserWithCompletionBlock:(void (^)(void))completionBlock failureBlock:(void (^)(void))failureBlock
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:master.identifier inContext:context];
    
    NSString *path = [NSString stringWithFormat:@"sd/following.json"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[user.identifier intValue]] ,@"Id", nil];
    
    [[SDAPIClient sharedClient] postPath:path
                              parameters:dict
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                     
                                     NSArray *results = [JSON objectForKey:@"Results"];
                                     NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                                     Master *master = [Master MR_findFirstByAttribute:@"username" withValue:masterUsername inContext:context];
                                     
                                     for (__strong NSDictionary *userInfo in results) {
                                         userInfo = [userInfo dictionaryByReplacingNullsWithStrings];
                                         NSNumber *followingsUserIdentifier = [userInfo valueForKey:@"UserId"];
                                         User *user = [User MR_findFirstByAttribute:@"identifier" withValue:followingsUserIdentifier inContext:context];
                                         
                                         if (!user) {
                                             user = [User MR_createInContext:context];
                                             user.identifier = followingsUserIdentifier;
                                         }
                                         user.username = [userInfo valueForKey:@"Username"];
                                         user.master = master;
                                         user.followedBy = master;
                                         user.avatarUrl = [userInfo valueForKey:@"AvatarUrl"];
                                         user.name = [userInfo valueForKey:@"DisplayName"];
                                         
                                         //                                         user.followingRelationshipCreated = [self dateFromString:[userInfo valueForKey:@"CreatedDate"]];
                                     }
                                     [context MR_saveToPersistentStoreAndWait];
                                     if (completionBlock)
                                         completionBlock();
                                     
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [SDErrorService handleError:error withOperation:operation];
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

#pragma mark - Get Offers for User
+ (void)getOffersForUser:(User *)user
         completionBlock:(void (^)(void))completionBlock
            failureBlock:(void (^)(void))failureBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/signingday.svc/OffersView?$format=json&$filter=(PlayerID eq %d)",kSDBaseSigningDayURLString,[user.identifier intValue]];
    
    [self startHTTPRequestOperationWithURLString:urlString
                           operationSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                               
                               NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                               
                               NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                    options:kNilOptions
                                                                                      error:nil];
                               user.thePlayer.offers = nil;
                               NSArray *array = [JSON valueForKey:@"d"];
                               
                               for (NSDictionary *dictionary in array) {
                                   
                                   NSDictionary *userDictionary = [dictionary dictionaryByReplacingNullsWithStrings];
                                   
                                   NSNumber *teamIdentifier = [NSNumber numberWithInt:[[userDictionary valueForKey:@"TeamID"] intValue]];
                                   User *teamUser = [User MR_findFirstByAttribute:@"identifier"
                                                                        withValue:teamIdentifier
                                                                        inContext:context];
                                   if (!teamUser) {
                                       teamUser = [User MR_createInContext:context];
                                       teamUser.identifier = teamIdentifier;
                                   }
                                   if (!teamUser.theTeam)
                                       teamUser.theTeam = [Team MR_createInContext:context];
                                   
                                   teamUser.userTypeId = [NSNumber numberWithInt:SDUserTypeTeam];
                                   teamUser.avatarUrl = [userDictionary valueForKey:@"TeamAvatarUrl"];
                                   
                                   teamUser.name = [userDictionary valueForKey:@"TeamInstitution"];
                                   
                                   Offer *offer = [Offer MR_createInContext:context];
                                   offer.playerCommited = [NSNumber numberWithBool:[[userDictionary valueForKey:@"IsCommited"] boolValue]];
                                   offer.player = user.thePlayer;
                                   offer.team = teamUser.theTeam;
                               }
                               
                               [context MR_saveOnlySelfAndWait];
                               if (completionBlock)
                                   completionBlock();
                           } operationFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                               
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