//
//  SDBaseLandingPageViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"
#import "SDLandingPageSearchBar.h"
#import "SDProfileService.h"
#import "SDFilterListViewController.h"
#import "SDUserProfileViewController.h"
#import "SDLandingPagesService.h"
#import "SDNavigationController.h"
#import "User.h"


@interface SDBaseLandingPageViewController : SDBaseViewController <SDFilterListDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int currentUserCount;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) UIView *searchBarBackground;

- (void)hideFilterView;
- (void)showFilterView;
- (int)heightForFilterHidingButton;
- (void)presentFilterListViewWithType:(FilterListType)listType andSelectedValue:(id)value;

@end
