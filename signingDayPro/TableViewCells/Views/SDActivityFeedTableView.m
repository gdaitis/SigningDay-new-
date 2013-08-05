//
//  SDActivityFeedTableView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedTableView.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "SDActivityFeedCell.h"
#import "ActivityStory.h"
#import "WebPreview.h"
#import "User.h"
#import "AFNetworking.h"
#import "SDActivityFeedCellContentView.h"
#import "SDCommentsViewController.h"
#import "SDUserProfileViewController.h"

@interface SDActivityFeedTableView ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDActivityFeedTableView

#pragma mark - initializers

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupDelegates];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupDelegates];
    }
    return self;
}

- (void)setupDelegates
{
    self.dataArray = nil;
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - activityFeed data source delegate

- (void)reloadTable
{
    [self reloadData];
}

#pragma mark - check server

- (void)checkServer
{
    [SDActivityFeedService getActivityStoriesForUser:self.user withDate:self.lastActivityStoryDate shouldDeleteOld:YES withSuccessBlock:^(NSDictionary *results){
        
        self.lastActivityStoryDate = [results objectForKey:@"LastDate"];
        
        if ([[results objectForKey:@"ResultCount"] intValue] == 0) {
            self.endReached = YES;
        }
        [self loadData];
        [self.tableDelegate activityFeedTableViewShouldEndRefreshing:self];
    } failureBlock:^{
        [self.tableDelegate activityFeedTableViewShouldEndRefreshing:self];
    }];
}

- (void)checkNewStories
{
    [SDActivityFeedService getActivityStoriesForUser:self.user withDate:nil shouldDeleteOld:NO withSuccessBlock:^(NSDictionary *results){
        
        BOOL listChanged = [[results valueForKey:@"ListChanged"] boolValue];
        if (listChanged) {
            [self loadData];
            [self.tableDelegate activityFeedTableViewShouldEndRefreshing:self];
        }
        else {
            [self.tableDelegate activityFeedTableViewShouldEndRefreshing:self];
        }
    } failureBlock:^{
        [self.tableDelegate activityFeedTableViewShouldEndRefreshing:self];
    }];
}

#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.dataArray count]) {
        ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
        
        int contentHeight = [SDUtils heightForActivityStory:activityStory];
        int result = 114/*buttons images etc..*/ + contentHeight;
        
        return result;
    }
    else {
        return 60;
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (!self.endReached) {
        return [self.dataArray count] +1;
    }
    else {
        return [self.dataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.dataArray count]) {
        
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
        }
        
        [cell.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.playerNameButton addTarget:self action:@selector(playerNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        
        ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];

        [cell.thumbnailImageView cancelImageRequestOperation];
        cell.likeButton.tag = indexPath.row;
        cell.commentButton.tag = indexPath.row;
        
        cell.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likesCount intValue]];
        if ([activityStory.likedByMaster boolValue])
            cell.likeCountLabel.textColor = [UIColor redColor];
        else
            cell.likeCountLabel.textColor = [UIColor grayColor];
        cell.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.commentCount intValue]];
        [cell.resizableActivityFeedView setActivityStory:activityStory];
        
        if ([activityStory.author.avatarUrl length] > 0) {
            [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:activityStory.author.avatarUrl]];
        }
        
        cell.postDateLabel.text = [SDUtils formatedTimeForDate:activityStory.createdDate];
        [cell setupNameLabelForActivityStory:activityStory];
        
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIActivityIndicatorViewStyle activityViewStyle = UIActivityIndicatorViewStyleGray;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.headerInfoDownloading) {
            [self checkServer];
        }
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.customHeaderView)
    {
        return self.customHeaderView;
    }
    else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 6)];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.customHeaderView)
    {
        return self.customHeaderView.frame.size.height;
    }
    else {
        return 6;
    }
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
    if (activityStory.webPreview) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:activityStory.webPreview.link]];
    }
}

#pragma mark - 

- (void)loadData
{
    if (self.user) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", self.user];
        self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    else {
        self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }

    [self reloadTable];
}

#pragma mark - like/comment button pressed

- (void)likeButtonPressed:(UIButton *)sender
{
    ActivityStory *activityStoryFromArray = [self.dataArray objectAtIndex:sender.tag];
    NSManagedObjectContext *activityStoryContext = [NSManagedObjectContext MR_contextForCurrentThread];
    ActivityStory *activityStoryInContext = [activityStoryFromArray MR_inContext:activityStoryContext];
    
    BOOL likeStatus;
    int likeInt;
    if ([activityStoryInContext.likedByMaster boolValue]) {
        likeStatus = NO;
        likeInt = -1;
    } else {
        likeStatus = YES;
        likeInt = +1;
    }
    activityStoryInContext.likedByMaster = [NSNumber numberWithBool:likeStatus];
    NSNumber *newNumberOfLikes = [NSNumber numberWithInt:([activityStoryInContext.likesCount integerValue] + likeInt)];
    activityStoryInContext.likesCount = newNumberOfLikes;
    
    [activityStoryContext MR_saveOnlySelfAndWait];
    
    [self loadData];
    
    if (likeStatus) {
        [SDActivityFeedService likeActivityStory:activityStoryInContext
                                    successBlock:^{
                                        [self checkServer];
                                    } failureBlock:^{
                                        NSLog(@"Liking failed");
                                    }];
    } else {
        [SDActivityFeedService unlikeActivityStory:activityStoryInContext
                                      successBlock:^{
                                          [self checkServer];
                                      } failureBlock:^{
                                          NSLog(@"Unliking failed");
                                      }];
    }
    
}

- (void)commentButtonPressed:(UIButton *)sender
{
    ActivityStory *activityStory = [self.dataArray objectAtIndex:sender.tag];
    UIStoryboard *commentsViewStoryboard = [UIStoryboard storyboardWithName:@"CommentsViewStoryboard"
                                                                     bundle:nil];
    SDCommentsViewController *commentsViewController = [commentsViewStoryboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    commentsViewController.activityStory = activityStory;
    
    [self.tableDelegate activityFeedTableView:self
                    wantsNavigateToController:commentsViewController];
}

- (void)playerNameButtonPressed:(UIButton *)sender
{
    User *user = nil;
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                     bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = user;
    
    [self.tableDelegate activityFeedTableView:self
                    wantsNavigateToController:userProfileViewController];
}



@end
