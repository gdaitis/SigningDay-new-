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


@interface SDUserProfileViewController ()

@property (nonatomic, weak) IBOutlet SDTableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) SDUserProfileHeaderView *headerView;

@end

@implementation SDUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadActivityFeedInfo];
}


#pragma mark - ActivityStories data loading/displaying

- (void)loadActivityFeedInfo
{
    [self showProgressHudInView:self.view withText:@"Loading"];
    [SDActivityFeedService getActivityStoriesForUser:_currentUser withSuccessBlock:^{
        [self reloadActivityData];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
}

-(void)reloadActivityData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", _currentUser];
    self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO withPredicate:predicate];
    [self.tableView reloadData];
    
    NSLog(@"tableview height = %f",_tableView.frame.size.height);
}


#pragma mark - TableView datasource

- (void)setupHeaderView
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kUserProfileHeaderHeight;
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
    ActivityStory *activityStory = [_dataArray objectAtIndex:indexPath.row];
    
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
        //[self setupCell:cell];
    } else {
        [cell.thumbnailImageView cancelImageRequestOperation];
    }
    
    cell.likeButton.tag = indexPath.row;
    cell.commentButton.tag = indexPath.row;
    
    ActivityStory *activityStory = [_dataArray objectAtIndex:indexPath.row];
    
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

#pragma mark UITableView delegate mothods

@end
