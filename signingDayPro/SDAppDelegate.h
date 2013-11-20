//
//  SDAppDelegate.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import "GAITracker.h"

extern NSString * const kSDAppDelegatePushNotificationReceivedNotification;

@interface SDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) FBSession *fbSession;
@property (nonatomic, strong) NSString* deviceToken;
@property (nonatomic, strong) ACAccount *twitterAccount;

@property (nonatomic, strong) id<GAITracker> tracker;

@end
