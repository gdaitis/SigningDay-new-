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


@interface SDUserProfileViewController () <NSFetchedResultsControllerDelegate,SDActivityFeedTableViewDelegate>
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
    
    UIColor *backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
    
    self.tableView.user = self.currentUser;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tableView.activityStoryCount = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    self.tableView.user = self.currentUser;
    self.tableView.tableDelegate = self;
    [self setupTableViewHeader];
}

#pragma mark - refreshing

- (void)checkServer
{
    [self.tableView checkNewStories];
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
                
                SDUserProfileMemberHeaderView* memberHeaderView = (id)currentObject;
                memberHeaderView.delegate = self;
                self.headerView = memberHeaderView;

                break;
            }
        }
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

#pragma mark - header data loading delegates

- (void)dataLoadingFinishedInHeaderView:(id)headerView
{
    self.tableView.headerInfoDownloading = NO;
    [self.tableView checkServer];
}

- (void)dataLoadingFailedInHeaderView:(id)headerView
{
    self.tableView.headerInfoDownloading = NO;
    [self.tableView checkServer];
}

- (void)shouldEndRefreshing
{
    [self endRefreshing];
}

@end
