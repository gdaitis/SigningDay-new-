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
#import "SDUserProfileHeaderView.h"
#import "SDTableView.h"
#import "User.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "SDActivityFeedCell.h"
#import "ActivityStory.h"
#import "SDActivityFeedCellContentView.h"
#import "SDImageService.h"
#import "AFNetworking.h"

#define kUserProfileHeaderHeight 360
#define kUserProfileHeaderHeightWithBuzzButtonView 450


@interface SDUserProfileViewController () <NSFetchedResultsControllerDelegate>
{
    BOOL _isMasterProfile;
}

@property (nonatomic, strong) IBOutlet SDTableView *tableView;
@property (atomic, strong) NSArray *dataArray;
@property (nonatomic, strong) SDUserProfileHeaderView *headerView;

@end


@implementation SDUserProfileViewController

#pragma mark - View loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //chechking if user is view his own profile, depending on this we show or remove buzz button view
    if ([_currentUser.identifier isEqualToNumber:[self getMasterIdentifier]]) {
        _isMasterProfile = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self beginRefreshing];
    [self loadActivityFeedInfo];
}


#pragma mark - ActivityStories data loading/displaying

- (void)loadActivityFeedInfo
{
    [SDActivityFeedService getActivityStoriesForUser:_currentUser withSuccessBlock:^{
        [self reloadActivityData];
        [self endRefreshing];
    } failureBlock:^{
        [self endRefreshing];
    }];
}

-(void)reloadActivityData
{
    [self.tableView reloadData];
    
    NSLog(@"tableview height = %f",self.tableView.frame.size.height);
}

#pragma mark - TableView datasource

- (void)setupHeaderView
{
    if (_isMasterProfile) {
        _headerView.buzzButtonView.hidden = YES;
    }
    else {
        _headerView.buzzButtonView.hidden = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", _currentUser];
    self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO withPredicate:predicate];
    return [_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _isMasterProfile ? kUserProfileHeaderHeight : kUserProfileHeaderHeightWithBuzzButtonView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_headerView) {
        // Load headerview
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDUserProfileHeaderView" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDUserProfileHeaderView class]]) {
                self.headerView = currentObject;
                break;
            }
        }
        [self setupHeaderView];
    }
    
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
    
    int contentHeight = [SDUtils heightForActivityStory:activityStory];
    int result = 120/*buttons images etc..*/ + contentHeight;
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDActivityFeedCell *cell = nil;
    NSString *cellIdentifier = @"ActivityFeedCellId";
    
    cell = (SDActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Load cell
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDActivityFeedCell" owner:nil options:nil];
        // Grab cell reference which was set during nib load:
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDActivityFeedCell class]]) {
                cell = currentObject;
                break;
            }
        }
    } else {
        [cell.thumbnailImageView cancelImageRequestOperation];
    }
    
    cell.likeButton.tag = indexPath.row;
    cell.commentButton.tag = indexPath.row;
    
    ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likes count]];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.comments count]];
    cell.nameLabel.text =activityStory.author.name;
    [cell.resizableActivityFeedView setActivityStory:activityStory];
    
    if ([activityStory.author.avatarUrl length] > 0) {
        [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:activityStory.author.avatarUrl]];
    }
    
    cell.postDateLabel.text = [SDUtils formatedTimeForDate:activityStory.createdDate];
    cell.yearLabel.text = @"- DE, 2014";
    
    return cell;
}

@end
