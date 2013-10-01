//
//  SDNotificationViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/20/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseToolbarItemViewController.h"

@class SDNotificationViewController;
@class ActivityStory;

@protocol SDNotificationViewControllerDelegate <NSObject>

@optional

- (void)notificationViewController:(SDNotificationViewController *)notificationViewController
            didSelectActivityStory:(ActivityStory *)activityStory;

@end


@interface SDNotificationViewController : SDBaseToolbarItemViewController

@property (nonatomic, weak) id <SDNotificationViewControllerDelegate> delegate;

-(void)loadInfo;

@end
