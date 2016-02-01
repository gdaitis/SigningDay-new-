//
//  SDFollowingViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/31/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseToolbarItemViewController.h"
#import "User.h"

typedef enum {
    
	CONTROLLER_TYPE_FOLLOWING = 0,
	CONTROLLER_TYPE_FOLLOWERS
} ControllerType;

@class SDFollowingViewController;

@protocol SDFollowingViewControllerDelegate <NSObject>

@optional

- (void)followingViewController:(SDFollowingViewController *)followingViewController didSelectUser:(User *)user;

@end

@interface SDFollowingViewController : SDBaseToolbarItemViewController <UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, assign) ControllerType controllerType;
@property (nonatomic, weak) id <SDFollowingViewControllerDelegate> delegate;

- (void)loadInfo;

@end
