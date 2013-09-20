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

#define kPageCountForLandingPages 10

@interface SDBaseLandingPageViewController : SDBaseViewController <SDFilterListDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int currentUserCount;


@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *customSearchDisplayController;
@property (nonatomic, weak) UIView *searchBarBackground;

//flags for landing page data following
@property (nonatomic, assign) BOOL dataDownloadInProgress;
@property (nonatomic, assign) BOOL pagingEndReached;
@property (nonatomic, assign) BOOL dataIsFiltered;

- (void)hideFilterView;
- (void)removeKeyboard;
- (void)showFilterView;
- (int)heightForFilterHidingButton;
- (void)presentFilterListViewWithType:(FilterListType)listType andSelectedValue:(id)value;
- (void)reloadTableView;
- (void)loadFilteredData;

@end
