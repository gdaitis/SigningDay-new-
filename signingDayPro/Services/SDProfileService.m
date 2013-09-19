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
#import "Coach.h"
#import "Team.h"
#import "Member.h"
#import "HighSchool.h"
#import "NSDictionary+NullConverver.h"
#import "NSObject+MasterUserMethods.h"

@interface SDProfileService ()

+ (void)uploadAvatarForUserIdentifier:(NSNumber *)identifier
                           verbMethod:(NSString *)verbMethod
            constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
                      completionBlock:(void (^)(void))completionBlock;

@end

@implementation SDProfileService

+ (void)getProfileInfoForUser:(User *)theUser
              completionBlock:(void (^)(void))completionBlock
                 failureBlock:(void (^)(void))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@services/UserService.asmx/GetUserInfo", kSDBaseSigningDayURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"json" forHTTPHeaderField:@"Data-Type"];
    NSString *body = [NSString stringWithFormat:@"{userId:%d, accessingUserId:%d}", [theUser.identifier integerValue], [[self getMasterIdentifier] integerValue]];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id data) {
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:nil] dictionaryByReplacingNullsWithStrings];
        NSDictionary *userDictionary = [JSON valueForKey:@"d"];
        
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
        
        NSDictionary *derivedUserDictionary = [userDictionary valueForKey:@"DerivedUser"];
        
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
                
                NSDictionary *highSchoolDictionary = [derivedUserDictionary valueForKey:@"HighSchool"];
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
                
                user.thePlayer.highSchool = highSchoolUser.theHighSchool;
            }
                break;
                
            case SDUserTypeTeam: {
                if (!user.theTeam)
                    user.theTeam = [Team MR_createInContext:userContext];
                NSDictionary *conferenceDictionary = [derivedUserDictionary valueForKey:@"Conference"];
                user.theTeam.conferenceName = [conferenceDictionary valueForKey:@"Name"];
                user.theTeam.conferenceLogoUrl = [conferenceDictionary valueForKey:@"LogoUrl"];
                user.theTeam.conferenceLogoUrlBlack = [conferenceDictionary valueForKey:@"LogoUrlBlack"];
                user.theTeam.location = [derivedUserDictionary valueForKey:@"Location"];
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
                
                user.theTeam.headCoach = coachUser.theCoach;
            }
                break;
                
            case SDUserTypeCoach: {
                if (!user.theCoach)
                    user.theCoach = [Coach MR_createInContext:userContext];
                user.theCoach.location = [derivedUserDictionary valueForKey:@"Location"];
                user.theCoach.position = [derivedUserDictionary valueForKey:@"Position"];
                
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
                        
                        user.theMember.favoriteTeam = teamUser.theTeam;
                    }
                }
            }
                break;
                
            default:
                break;
        }
        
        [userContext MR_saveOnlySelfAndWait];
        
        completionBlock();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
    [operation start];
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
                     NSDictionary *userDictionary = [JSON objectForKey:@"User"];
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



#pragma mark

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
                                     
                                     for (NSDictionary *userInfo in results) {
                                         
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



@end





























