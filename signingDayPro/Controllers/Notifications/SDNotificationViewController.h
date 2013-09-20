//
//  SDNotificationViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/20/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class SDNotificationViewController;
@class User;

@protocol SDNotificationViewControllerDelegate <NSObject>

@optional

- (void)notificationViewController:(SDNotificationViewController *)notificationViewController didSelectUser:(User *)user;

@end


@interface SDNotificationViewController : SDBaseViewController

@property (nonatomic, weak) id <SDNotificationViewControllerDelegate> delegate;

-(void)loadInfo;

@end
