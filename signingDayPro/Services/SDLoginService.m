//
//  SDLoginService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDLoginService.h"
#import "SDAPIClient.h"
#import "STKeychain.h"
#import "Master.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"
#import "SDErrorService.h"
#import "User.h"
#import "SDActivityFeedService.h"
#import "NSDictionary+NullConverver.h"
#import "UIImage+fixOrientation.h"
#import <AFNetworking.h>

NSString * const kSDLoginServiceUserDidLogoutNotification = @"SDLoginServiceUserDidLogoutNotificationName";

@implementation SDLoginService

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password facebookToken:(NSString *)facebookToken successBlock:(void (^)(void))successBlock failBlock:(void (^)(void))failBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (username)
        [parameters setValue:[username lowercaseString] forKey:@"Username"];
    if (password)
        [parameters setValue:password forKey:@"Password"];
    if (facebookToken)
        [parameters setValue:facebookToken forKey:@"FBAuthToken"];
    NSString *deviceName = [[UIDevice currentDevice] name];
    [parameters setValue:deviceName forKey:@"DeviceName"];
    NSString *systemName = [[UIDevice currentDevice] systemName];
    [parameters setValue:systemName forKey:@"DeviceOS"];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    [parameters setValue:osVersion forKey:@"DeviceOSVersion"];
    NSString *platform = @"1";
    [parameters setValue:platform forKey:@"Platform"];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    if (deviceToken == nil) {
        deviceToken = @"invalid_token";
    }
    NSLog(@"DEVICE_TOKEN: %@", deviceToken);
    
    [parameters setValue:deviceToken forKey:@"DeviceToken"];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Logging in";
    
    [[SDAPIClient sharedClient] setRestTokenHeaderWithToken:[STKeychain getPasswordForUsername:@"initialApiKey" andServiceName:@"SigningDayPro" error:nil]];
    [[SDAPIClient sharedClient] postPath:@"sd/clientdevices.json"
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id JSON) {
                                     [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                                     
                                     NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                                     NSString *anUsername;
                                     if (!username) {
                                         anUsername = [[JSON objectForKey:@"User"] valueForKey:@"Username"];
                                     } else {
                                         anUsername = username;
                                     }
                                     [[NSUserDefaults standardUserDefaults] setValue:anUsername forKey:@"username"];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     
                                     NSString *apiKey = [JSON objectForKey:@"ApiKey"];
                                     NSError *error;
                                     [STKeychain storeUsername:anUsername andPassword:apiKey forServiceName:@"SigningDayPro" updateExisting:YES error:&error];
                                     if (error) {
                                         NSLog(@"Error while saving to keychain.");
                                         exit(-1);
                                     }
                                     
                                     [[SDAPIClient sharedClient] setRestTokenHeaderWithToken:apiKey];
                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loggedIn"];
                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                     Master *master = [Master MR_findFirstByAttribute:@"username" withValue:anUsername inContext:context];
                                     if (!master) {
                                         master = [Master MR_createInContext:context];
                                         master.username = anUsername;
                                         master.identifier = @([JSON[@"User"][@"Id"] intValue]);
                                         master.photoGalleryId = [JSON objectForKey:@"PhotoGalleryId"];
                                         master.videoGalleryId = @([JSON[@"VideoGalleryId"] intValue]);
                                         
                                     }
                                     
                                     User *user = [User MR_findFirstByAttribute:@"username" withValue:anUsername inContext:context];
                                     if (!user) {
                                         user = [User MR_createInContext:context];
                                         user.identifier = @([JSON[@"User"][@"Id"] intValue]);
                                     }
                                     NSDictionary *userDictionary = [[JSON objectForKey:@"User"] dictionaryByReplacingNullsWithStrings];
                                     user.username = anUsername;
                                     user.avatarUrl = [userDictionary valueForKey:@"AvatarUrl"];
                                     user.name = [userDictionary valueForKey:@"DisplayName"];
                                     user.master = master;
                                     
                                     if (facebookToken)
                                         master.facebookSharingOn = [NSNumber numberWithBool:YES];
                                     else
                                         master.facebookSharingOn = [NSNumber numberWithBool:NO];
                                     
                                     [context MR_saveToPersistentStoreAndWait];
                                     
                                     [SDProfileService getProfileInfoForUser:user completionBlock:^{
                                         if (successBlock) {
                                             successBlock();
                                         }
                                     } failureBlock:^{
                                         failBlock();
                                     }];
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                                     
                                     [SDErrorService handleError:error withOperation:operation];
                                     failBlock();
                                 }];
}

+ (void)logoutWithSuccessBlock:(void (^)(void))successBlock
                  failureBlock:(void (^)(void))failureBlock
{
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    
    if (deviceToken) {
        [[SDAPIClient sharedClient] postPath:@"sd/logout.json"
                                  parameters:@{@"DeviceToken":deviceToken}
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         [self cleanUpUserSession];
                                         
                                         if (successBlock)
                                             successBlock();
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if ([error code] == -1011) {
                                             [self cleanUpUserSession];
                                             
                                             if (successBlock)
                                                 successBlock();
                                         } else {
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                             message:@"Server error: could not log out"
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"Ok"
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                             if (failureBlock)
                                                 failureBlock();
                                         }
                                     }];
    } else {
        [self cleanUpUserSession];
    }
}

+ (void)registerNewUserWithType:(SDUserType)userType
                       username:(NSString *)username
                       password:(NSString *)password
                          email:(NSString *)email
                    parentEmail:(NSString *)parentEmail
                 birthdayString:(NSString *)birthdayString
                  parentConsent:(BOOL)parentConsent
                   successBlock:(void (^)(void))successBlock
                   failureBlock:(void (^)(void))failureBlock
{
    /*
     REST service method: ~/api.ashx/v2/sd/registration.json
     HTTP method: POST
     Requires Rest-User-Token from user with admin role
     Allows registration of players and members only
     Request example:
     { UserType: 1, Username: "registeredplayer", Password: "123456", Email: "registeredplayer@gmail.com", ParentEmail: "parent159@gmail.com", Birthday: "12/18/2000", ParentConsent: true }
    */
    
    NSString *key = [STKeychain getPasswordForUsername:@"initialApiKey"
                                        andServiceName:@"SigningDayPro"
                                                 error:nil];
    [[SDAPIClient sharedClient] setRestTokenHeaderWithToken:key];
    NSDictionary *params = @{@"UserType": [NSNumber numberWithInt:userType],
                             @"Username": username,
                             @"Password": password,
                             @"Email": email,
                             @"ParentEmail": parentEmail,
                             @"Birthday": birthdayString,
                             @"ParentConsent": @"true"};
    [[SDAPIClient sharedClient] postPath:@"sd/registration.json"
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if (successBlock)
                                         successBlock();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if (failureBlock)
                                         failureBlock();
                                 }];
}

+ (void)claimUserForUserIdentifier:(NSNumber *)identifier
                             email:(NSString *)email
                             phone:(NSString *)phone
                             image:(UIImage *)image
                      successBlock:(void (^)(void))successBlock
                      failureBlock:(void (^)(void))failureBlock
{
    NSDate *todayDateObj = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"ddMMyyyyHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"photo%@.jpg", [dateFormat stringFromDate:todayDateObj]];
    
    NSString *key = [STKeychain getPasswordForUsername:@"initialApiKey"
                                        andServiceName:@"SigningDayPro"
                                                 error:nil];
    [[SDAPIClient sharedClient] setRestTokenHeaderWithToken:key];
    NSMutableURLRequest *request = [[SDAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                         path:@"sd/accountclaims.json"
                                                                                   parameters:@{@"UserId": identifier,
                                                                                                @"Email": email,
                                                                                                @"Phone": phone,
                                                                                                @"FileName": fileName}
                                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                        UIImage *fixedImage = [image fixOrientation];
                                                                        NSData *imageData = UIImageJPEGRepresentation(fixedImage, 1);
                                                                        
                                                                        [formData appendPartWithFileData:imageData
                                                                                                    name:@"FileData"
                                                                                                fileName:fileName
                                                                                                mimeType:@"image/jpeg"];
                                                                    }];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Uploading image";
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        hud.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"Upload successful";
        [hud hide:YES afterDelay:3];
        
        if (successBlock)
            successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1009 || error.code == -1011) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Upload unsuccessful"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        [MBProgressHUD hideAllHUDsForView:appDelegate.window
                                 animated:YES];
    }];
    
    [operation start];
}

+ (void)cleanUpUserSession
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.fbSession close];
    appDelegate.twitterAccount = nil;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    master.facebookSharingOn = [NSNumber numberWithBool:NO];
    [context MR_saveToPersistentStoreAndWait];
    
    //delete all activityStories
    [SDActivityFeedService deleteAllActivityStories];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"loggedIn"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end