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
#import "SDUserProfileTeamHeaderView.h"
#import "User.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "SDActivityFeedCell.h"
#import "ActivityStory.h"
#import "SDActivityFeedCellContentView.h"
#import "SDImageService.h"
#import "SDActivityFeedTableView.h"
#import "AFNetworking.h"

#define kUserProfileHeaderHeight 360
#define kUserProfileHeaderHeightWithBuzzButtonView 450


@interface SDUserProfileViewController () <NSFetchedResultsControllerDelegate>
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
    
    //chechking if user is view his own profile, depending on this we show or remove buzz button view
#warning FIXME logic for all profiles
    if ([_currentUser.identifier isEqualToNumber:[self getMasterIdentifier]]) {
        _isMasterProfile = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self beginRefreshing];
    
    self.tableView.activityStoryCount = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    self.tableView.user = self.currentUser;
    [self setupTableViewHeader];
    
    [self.tableView checkServer];
}

#pragma mark - refreshing

- (void)beginRefreshing
{
    [super beginRefreshing];
    [self.tableView checkNewStories];
}

- (void)endRefreshing
{
    [super endRefreshing];
}

#pragma mark - TableView datasource

- (void)setupTableViewHeader
{
    if (!_headerView) {
        
        // Load headerview
        NSArray *topLevelObjects = nil;
        
#warning FIXME logic for all profiles
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDUserProfileMemberHeaderView" owner:nil options:nil];
        //        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDUserProfilePlayerHeaderView" owner:nil options:nil];
        //        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDUserProfileTeamHeaderView" owner:nil options:nil];
        //        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDUserProfileCoachHeaderView" owner:nil options:nil];
        
        
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDUserProfileMemberHeaderView class]]) {
                //            if([currentObject isKindOfClass:[SDUserProfileCoachHeaderView class]]) {
                //            if([currentObject isKindOfClass:[SDUserProfileTeamHeaderView class]]) {
                //            if([currentObject isKindOfClass:[SDUserProfilePlayerHeaderView class]]) {
                self.headerView = currentObject;
                break;
            }
        }
        [self setupHeaderView];
    }
    self.tableView.tableHeaderView = self.headerView;
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

#pragma mark - header data loading delegates

- (void)dataLoadingFinishedInHeaderView:(id)headerView
{
    [self endRefreshing];
}

@end
