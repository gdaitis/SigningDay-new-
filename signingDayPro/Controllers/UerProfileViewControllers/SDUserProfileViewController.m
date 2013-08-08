//
//  SDViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileViewController.h"
#import "SDMenuViewController.h"
#import "SDProfileService.h"
#import "SDUserProfileMemberHeaderView.h"
#import "SDUserProfilePlayerHeaderView.h"
#import "SDTableView.h"
#import "SDUserProfileCoachHeaderView.h"
#import "SDUserProfileHighSchoolHeaderView.h"
#import "SDUserProfileTeamHeaderView.h"
#import "User.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "ActivityStory.h"
#import "SDActivityFeedCellContentView.h"
#import "SDImageService.h"
#import "SDActivityFeedTableView.h"
#import "AFNetworking.h"
#import "UIView+NibLoading.h"
#import "SDBuzzButtonView.h"
#import "SDModalNavigationController.h"
#import "SDBuzzSomethingViewController.h"

#define kUserProfileHeaderHeight 360
#define kUserProfileHeaderHeightWithBuzzButtonView 450


@interface SDUserProfileViewController () <NSFetchedResultsControllerDelegate, SDActivityFeedTableViewDelegate, SDBuzzButtonViewDelegate, SDModalNavigationControllerDelegate>
{
    BOOL _isMasterProfile;
}

@property (nonatomic, strong) IBOutlet SDActivityFeedTableView *tableView;
@property (atomic, strong) NSArray *dataArray;
@property (nonatomic, strong) id headerView;    //may be different depending on user

@end


@implementation SDUserProfileViewController

#pragma mark - View loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //chechking if user is viewing his own profile, depending on this we show or remove buzz button view
    if ([_currentUser.identifier isEqualToNumber:[self getMasterIdentifier]]) {
        _isMasterProfile = YES;
    }
    
    UIColor *backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
    
    self.tableView.user = self.currentUser;
    self.tableView.activityStoryCount = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    self.tableView.user = self.currentUser;
    self.tableView.tableDelegate = self;
    [self setupTableViewHeader];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView loadData];
}

#pragma mark - refreshing

- (void)checkServer
{
    self.tableView.activityStoryCount = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    [self.tableView checkServerAndDeleteOld:NO];
}

#pragma mark - TableView datasource

- (void)setupTableViewHeader
{
    if (!_headerView) {
        
        // Load headerview
        id view = nil;
        switch ([self.currentUser.userTypeId intValue]) {
            case SDUserTypePlayer:
                view = [UIView loadInstanceFromClass:[SDUserProfilePlayerHeaderView class]];
                ((SDUserProfilePlayerHeaderView *)view).delegate = self;
                ((SDUserProfilePlayerHeaderView *)view).buzzButtonView.delegate = self;
                break;
            case SDUserTypeHighSchool:
                view = [UIView loadInstanceFromClass:[SDUserProfileHighSchoolHeaderView class]];
                ((SDUserProfileHighSchoolHeaderView *)view).delegate = self;
                ((SDUserProfileHighSchoolHeaderView *)view).buzzButtonView.delegate = self;
                break;
            case SDUserTypeTeam:
                view = [UIView loadInstanceFromClass:[SDUserProfileTeamHeaderView class]];
                ((SDUserProfileTeamHeaderView *)view).delegate = self;
                ((SDUserProfileTeamHeaderView *)view).buzzButtonView.delegate = self;
                break;
            case SDUserTypeMember:
                view = [UIView loadInstanceFromClass:[SDUserProfileMemberHeaderView class]];
                ((SDUserProfileMemberHeaderView *)view).delegate = self;
                ((SDUserProfileMemberHeaderView *)view).buzzButtonView.delegate = self;
                break;
            case SDUserTypeCoach:
                view = [UIView loadInstanceFromClass:[SDUserProfileCoachHeaderView class]];
                ((SDUserProfileCoachHeaderView *)view).delegate = self;
                ((SDUserProfileCoachHeaderView *)view).buzzButtonView.delegate = self;
                break;
            default:
                break;
        }
        
        self.headerView = view;
        self.tableView.headerInfoDownloading = YES;
        [self setupHeaderView];
    }
    self.tableView.customHeaderView = self.headerView;
}

- (void)setupHeaderView
{
    if (_isMasterProfile) {
        [_headerView hideBuzzButtonView:YES];
    }
    else {
        [_headerView hideBuzzButtonView:NO];
    }
    [_headerView setupInfoWithUser:_currentUser];
}

#pragma mark - SDActivityFeedTableView delegate methods

- (void)activityFeedTableViewShouldEndRefreshing:(SDActivityFeedTableView *)activityFeedTableView
{
    [self endRefreshing];
}

- (void)activityFeedTableView:(SDActivityFeedTableView *)activityFeedTableView
    wantsNavigateToController:(UIViewController *)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - header data loading delegates

- (void)dataLoadingFinishedInHeaderView:(id)headerView
{
    self.tableView.headerInfoDownloading = NO;
    [self.tableView checkServerAndDeleteOld:NO];
}

- (void)dataLoadingFailedInHeaderView:(id)headerView
{
    self.tableView.headerInfoDownloading = NO;
    [self.tableView checkServerAndDeleteOld:NO];
}

- (void)shouldEndRefreshing
{
    [self endRefreshing];
}

#pragma mark - Buzz buttonView delegates

- (void)buzzSomethingButtonPressedInButtonView:(SDBuzzButtonView *)buzzButtonView
{
    SDModalNavigationController *modalNavigationViewController = [[SDModalNavigationController alloc] init];
    modalNavigationViewController.myDelegate = self;
    SDBuzzSomethingViewController *buzzSomethingViewController = [[UIStoryboard storyboardWithName:@"ActivityFeedStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"BuzzSomethingViewController"];
    buzzSomethingViewController.user = self.currentUser;
    [modalNavigationViewController addChildViewController:buzzSomethingViewController];
    [self presentViewController:modalNavigationViewController
                       animated:YES
                     completion:nil];
}

- (void)messageButtonPressedInButtonView:(SDBuzzButtonView *)buzzButtonView
{
    
}

#pragma mark - SDModalNavigationController myDelegate methods

- (void)modalNavigationControllerWantsToClose:(SDModalNavigationController *)modalNavigationController
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self checkServer];
                             }];
}

@end
