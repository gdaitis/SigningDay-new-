//
//  SDUploadService.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/6/12.
//
//

#import "SDUploadService.h"
#import "SDAPIClient.h"
#import "AFNetworking.h"
#import "UIImage+fixOrientation.h"
#import "MBProgressHUD.h"
#import "SDAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Master.h"
#import <Twitter/Twitter.h>
#import "SDErrorService.h"
#import "User.h"
#import "NSDictionary+NullConverver.h"

//NSString * const kSDLogoURLString = @"https://www.dev.signingday.com/cfs-file.ashx/__key/communityserver-components-sitefiles/SD-logo.png";

@interface SDUploadService ()

+ (void)postToTwitterWithTitle:(NSString *)title
                   description:(NSString *)description
                          link:(NSString *)link;

@end

@implementation SDUploadService

+ (void)postToTwitterWithTitle:(NSString *)title
                   description:(NSString *)description
                          link:(NSString *)link
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *status = [NSString stringWithFormat:@"%@: %@, %@", title, description, link];
    [params setObject:status forKey:@"status"];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:params];
    [request setAccount:appDelegate.twitterAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!responseData) {
            [SDErrorService handleError:error withOperation:nil];
        }
        else {
            NSLog(@"Posting to twitter succeeded");
        }
    }];
}

+ (void)uploadPhotoImage:(UIImage *)image
               withTitle:(NSString *)title
             description:(NSString *)description
                    tags:(NSString *)tags
         facebookSharing:(BOOL)facebookSharing
          twitterSharing:(BOOL)twitterSharing
         completionBlock:(void (^)(void))completionBlock
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    
    NSString *path = [NSString stringWithFormat:@"media/%@/files.json", master.photoGalleryId];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:title, @"Name", description, @"Description", tags, @"Tags", nil];
    NSMutableURLRequest *request = [[SDAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                         path:path
                                                                                   parameters:parameters
                                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                        NSDate *todayDateObj = [NSDate date];
                                                                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                                                        [dateFormat setDateFormat:@"ddMMyyyyHHmmss"];
                                                                        NSString *fileName = [NSString stringWithFormat:@"photo%@.jpg", [dateFormat stringFromDate:todayDateObj]];
                                                                        
                                                                        UIImage *fixedImage = [image fixOrientation];
                                                                        NSData *imageData = UIImageJPEGRepresentation(fixedImage, 1);
                                                                        
                                                                        [formData appendPartWithFileData:imageData name:title fileName:fileName mimeType:@"image/jpeg"];
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
        
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil] dictionaryByReplacingNullsWithStrings];
        NSDictionary *mediaDictionary = [JSON objectForKey:@"Media"];
        NSString *link = [mediaDictionary valueForKey:@"Url"];
        NSString *title = [mediaDictionary valueForKey:@"Title"];
        NSString *description = [mediaDictionary valueForKey:@"Description"];
        NSString *thumbnailUrlString = [self getThumbnailPictureUrlStringFromFileUrlString:[[mediaDictionary valueForKey:@"File"] valueForKey:@"FileUrl"]];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        
        if (facebookSharing) {
            if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
                appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
            }
            [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                NSLog(@"FB access token: %@", appDelegate.fbSession.accessTokenData.accessToken);
                if (status == FBSessionStateOpen) {
                    master.facebookSharingOn = [NSNumber numberWithBool:YES];
                    [context MR_saveToPersistentStoreAndWait];
                }
            }];
            
            NSMutableDictionary *fbPostParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 link, @"link",
                                                 thumbnailUrlString, @"picture",
                                                 title, @"name",
                                                 description, @"caption",
                                                 nil, @"description",
                                                 nil];
            FBRequest *fbRequest = [[FBRequest alloc] initWithSession:appDelegate.fbSession
                                                            graphPath:@"me/feed"
                                                           parameters:fbPostParams
                                                           HTTPMethod:@"POST"];
            FBRequestConnection *fbRequestConnection = [[FBRequestConnection alloc] init];
            [fbRequestConnection addRequest:fbRequest
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSLog(@"Sharing to Facebook succeeded");
                              } else {
                                  NSLog(@"Sharing to Facebook failed: %@", [error description]);
                              }
                          }];
            [fbRequestConnection start];
        }
        
        if (twitterSharing) {
            if (!appDelegate.twitterAccount) {
            ACAccountStore *store = [[ACAccountStore alloc] init];
            ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [store requestAccessToAccountsWithType:twitterAccountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error) {
                                            if (!granted) {
                                                NSLog(@"User rejected access to the account.");
                                                
                                                master.twitterSharingOn = [NSNumber numberWithBool:NO];
                                                [context MR_saveToPersistentStoreAndWait];
                                            } else {
                                                master.twitterSharingOn = [NSNumber numberWithBool:YES];
                                                [context MR_saveToPersistentStoreAndWait];
                                                
                                                NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                                if ([twitterAccounts count] > 0) {
                                                    
                                                    ACAccount *account = [twitterAccounts objectAtIndex:0];
                                                    appDelegate.twitterAccount = account;
                                                }
                                                [self postToTwitterWithTitle:title
                                                                 description:description
                                                                        link:link];
                                            }
                                        }];
            } else {
                [self postToTwitterWithTitle:title
                                 description:description
                                        link:link];
            }
        }
        
        if (completionBlock)
            completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1009) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Upload unsuccessful"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if (error.code == -1011) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"A file with this title already exists. Please enter a different title."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    }];
    
    [operation start];
}

+ (NSString *)getThumbnailPictureUrlStringFromFileUrlString:(NSString *)urlString
{
    NSArray *components = [urlString pathComponents];
    NSString *lastComponent = [components lastObject];
    NSString *secondToLastComponent = [components objectAtIndex:[components count] - 2];
    NSString *thumbnailUrlString = [NSString stringWithFormat:@"%@cfs-filesystemfile.ashx/__key/communityserver-components-secureimagefileviewer/telligent-evolution-components-attachments-%@/%@__2D00_320x240.jpg", kSDBaseSigningDayURLString, secondToLastComponent, lastComponent];
    
    return thumbnailUrlString;
}

+ (void)uploadVideoWithURL:(NSURL *)URL
                 withTitle:(NSString *)title
               description:(NSString *)description
                      tags:(NSString *)tags
           facebookSharing:(BOOL)facebookSharing
            twitterSharing:(BOOL)twitterSharing
           completionBlock:(void (^)(void))completionBlock
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    
    NSString *path = [NSString stringWithFormat:@"media/%@/files.json", master.videoGalleryId];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:title, @"Name", description, @"Description", tags, @"Tags", nil];
    NSMutableURLRequest *request = [[SDAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                         path:path
                                                                                   parameters:parameters
                                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                        
                                                                        NSDate *todayDateObj = [NSDate date];
                                                                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                                                        [dateFormat setDateFormat:@"ddMMyyyyHHmmss"];
                                                                        NSString *fileName = [NSString stringWithFormat:@"video%@.mov",
                                                                                              [dateFormat stringFromDate:todayDateObj]];
                                                                        NSData *videoData = [NSData dataWithContentsOfURL:URL];
                                                                        
                                                                        [formData appendPartWithFileData:videoData
                                                                                                    name:title
                                                                                                fileName:fileName
                                                                                                mimeType:@"video/quicktime"];
                                                                    }];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Uploading video";
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        hud.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
        
        NSDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil] dictionaryByReplacingNullsWithStrings];
        NSDictionary *mediaDictionary = [JSON objectForKey:@"Media"];
        NSString *link = [mediaDictionary valueForKey:@"Url"];
        NSString *pictureLink = [[mediaDictionary objectForKey:@"File"] valueForKey:@"FileUrl"];
        NSString *title = [mediaDictionary valueForKey:@"Title"];
        NSString *description = [mediaDictionary valueForKey:@"Description"];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        
        if (facebookSharing) {
            if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
                appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
            }
            [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                NSLog(@"FB access token: %@", appDelegate.fbSession.accessTokenData.accessToken);
                if (status == FBSessionStateOpen) {
                    master.facebookSharingOn = [NSNumber numberWithBool:YES];
                    [context MR_saveToPersistentStoreAndWait];
                }
            }];
            
            NSMutableDictionary *fbPostParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 link, @"link",
                                                 pictureLink, @"picture",
                                                 title, @"name",
                                                 description, @"caption",
                                                 nil, @"description",
                                                 nil];
            FBRequest *fbRequest = [[FBRequest alloc] initWithSession:appDelegate.fbSession
                                                            graphPath:@"me/feed"
                                                           parameters:fbPostParams
                                                           HTTPMethod:@"POST"];
            FBRequestConnection *fbRequestConnection = [[FBRequestConnection alloc] init];
            [fbRequestConnection addRequest:fbRequest
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSLog(@"Sharing to Facebook succeeded");
                              } else {
                                  NSLog(@"Sharing to Facebook failed: %@", [error description]);
                              }
                          }];
            [fbRequestConnection start];
        }
        
        if (twitterSharing) {
            if (!appDelegate.twitterAccount) {
                ACAccountStore *store = [[ACAccountStore alloc] init];
                ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                
                [store requestAccessToAccountsWithType:twitterAccountType
                                               options:nil
                                            completion:^(BOOL granted, NSError *error) {
                                                if (!granted) {
                                                    NSLog(@"User rejected access to the account.");
                                                    
                                                    master.twitterSharingOn = [NSNumber numberWithBool:NO];
                                                    [context MR_saveToPersistentStoreAndWait];
                                                } else {
                                                    master.twitterSharingOn = [NSNumber numberWithBool:YES];
                                                    [context MR_saveToPersistentStoreAndWait];
                                                    
                                                    NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                                    if ([twitterAccounts count] > 0) {
                                                        
                                                        ACAccount *account = [twitterAccounts objectAtIndex:0];
                                                        appDelegate.twitterAccount = account;
                                                    }
                                                    [self postToTwitterWithTitle:title
                                                                     description:description
                                                                            link:link];
                                                }
                                            }];
            } else {
                [self postToTwitterWithTitle:title
                                 description:description
                                        link:link];
            }
        }
        
        if (completionBlock)
            completionBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == -1009) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Upload unsuccessful"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if (error.code == -1011) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"A file with this title already exists. Please enter a different title."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
    }];
    
    [operation start];
}

@end













