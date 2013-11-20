//
//  SDAppDelegate.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDAppDelegate.h"
#import "SDUtils.h"
#import "STKeychain.h"
#import "SDLoginService.h"
#import "SDUtils.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import "Master.h"
#import "DTCoreText.h"
#import "GAI.h"

NSString * const kSDAppDelegatePushNotificationReceivedNotification = @"SDAppDelegatePushNotificationReceivedNotification";

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-45419104-1"; //Testing id
static NSString *const kAllowTracking = @"allowTracking";

@implementation SDAppDelegate

@synthesize window = _window;
@synthesize fbSession = _fbSession;
@synthesize deviceToken = _deviceToken;
@synthesize twitterAccount = _twitterAccount;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@""] forBarMetrics:UIBarMetricsDefault];

    //checks for data migration, and setups suitable stack
    [SDUtils setupCoreDataStack];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 60;
    
#warning will change after tests
#ifdef DEBUG
//    [GAI sharedInstance].dryRun = YES;
#endif
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];

    //if master user got deleted, performing logout
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if (!master) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"loggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds =YES;
//        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
//        self.window.bounds = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height);
    }
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [STKeychain storeUsername:@"initialApiKey" andPassword:@"OGQ3MzZ4c205cWNtbzhiaHAxYnlqNzVqcGwzcWRhdDY6aU9T" forServiceName:@"SigningDayPro" updateExisting:NO error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionClosed) name:FBSessionDidBecomeClosedActiveSessionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionOpened) name:FBSessionDidBecomeOpenActiveSessionNotification object:nil];
    
    __unused DTCoreTextFontDescriptor *descriptor = [[DTCoreTextFontDescriptor alloc] init]; // <- pre-initializing the fonts required for faster loading
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.fbSession.state == FBSessionStateCreatedOpening) {
        [self.fbSession close];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Log in process was not complete" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord saveWithBlock:nil];
    
    [SDLoginService logoutWithSuccessBlock:nil failureBlock:nil];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"device token: %@", newToken);
    
    self.deviceToken = newToken;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDAppDelegatePushNotificationReceivedNotification
                                                        object:nil
                                                      userInfo:userInfo];
    
//    NSString *message = [NSString stringWithFormat:@"%@", userInfo];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Notifications testing"
//                                                    message:message
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Ok"
//                                          otherButtonTitles:nil];
//    [alert show];
}

- (void)setDeviceToken:(NSString *)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setValue:deviceToken
                                             forKey:@"deviceToken"];
    _deviceToken = deviceToken;
}

- (NSString *)deviceToken
{
    if (!_deviceToken)
        return [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    return _deviceToken;
}

#pragma mark - FBSession methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [self.fbSession handleOpenURL:url];
}

- (void)fbSessionOpened
{
    NSLog(@"Facebook session opened");
}

- (void)fbSessionClosed
{
    NSLog(@"Facebook session closed");
}

@end
