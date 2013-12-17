//
//  SDSharingService.m
//  SigningDay
//
//  Created by lite on 17/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDSharingService.h"
#import "SDAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import "NSObject+MasterUserMethods.h"
#import "Master.h"
#import "SDErrorService.h"

NSString * const kSDLogoURLString = @"https://www.dev.signingday.com/cfs-file.ashx/__key/communityserver-components-sitefiles/SD-logo.png";

@implementation SDSharingService

+ (void)shareString:(NSString *)string
        forFacebook:(BOOL)facebookSharing
         andTwitter:(BOOL)twitterSharing
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
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
        
        NSDictionary *fbPostParams = @{@"message":string};
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
                                                [self postToTwitterWithText:string];
                                            }
                                        }];
        } else {
            [self postToTwitterWithText:string];
        }
    }

}

+ (void)postToTwitterWithText:(NSString *)text
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *params = @{@"status":text};
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

@end
