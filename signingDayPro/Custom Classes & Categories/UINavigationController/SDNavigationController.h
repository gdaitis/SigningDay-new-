//
//  SDNavigationController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/27/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDMessageViewController.h"
#import "SDFollowingViewController.h"


typedef enum {
    BARBUTTONTYPE_NOTIFICATIONS = 0,
    BARBUTTONTYPE_CONVERSATIONS,
    BARBUTTONTYPE_FOLLOWERS,
    BARBUTTONTYPE_NONE
} BarButtonType;

#define kTriangleViewTag 999
#define kTopToolbarHeight 44

@interface SDNavigationController : UINavigationController <SDMessageViewControllerDelegate,SDFollowingViewControllerDelegate>

@property (nonatomic, weak) UIButton *menuButton;

@property (nonatomic, weak) UIToolbar *topToolBar;
@property (nonatomic, assign) BarButtonType *barButtonType;

@property (nonatomic, strong) SDMessageViewController *messageVC;
@property (nonatomic, strong) SDFollowingViewController *followingVC;

@property (nonatomic, assign) BarButtonType selectedMenuType;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL contentViewVisible;
@property (nonatomic, assign) BOOL backButtonVisibleIfNeeded; //if popup opened in the top toolbar, we should hide the back button;

- (void)setToolbarButtons;
- (void)popViewController;
- (void)setupToolbar;
- (void)showConversations;
- (void)revealMenu:(id)sender;

- (UIBarButtonItem *)barButtonForType:(BarButtonType)type;

@end
