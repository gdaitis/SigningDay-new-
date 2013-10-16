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
@property (nonatomic, assign) BOOL dataDownloadInProgress;

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

- (void)checkServerAndDeleteOld:(BOOL)deleteOld
{
    self.dataDownloadInProgress = YES;
    [SDActivityFeedService getActivityStoriesForUser:self.user
                                            withDate:self.lastActivityStoryDate
                                        andDeleteOld:deleteOld
                                    withSuccessBlock:^(NSDictionary *results){
                                        
                                        self.lastActivityStoryDate = [results objectForKey:@"LastDate"];
                                        if (deleteOld) {
                                            self.fetchLimit = 0;
                                        }
                                        
                                        if ([[results objectForKey:@"EndReached"] boolValue])
                                            self.endReached = YES;
                                        else
                                            self.fetchLimit += [[results objectForKey:@"ResultCount"] intValue];
                                        
                                        self.dataDownloadInProgress = NO;
                                        [self loadData];
                                        [self.tableDelegate activityFeedTableViewShouldEndRefreshing:self];
                                    } failureBlock:^{
                                        [self.tableDelegate activityFeedTableViewShouldEndRefreshing:self];
                                        self.dataDownloadInProgress = NO;
                                    }];
}

#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.dataArray count]) {
        ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
        
        int contentHeight = [SDUtils heightForActivityStory:activityStory];
        int result = 119/*buttons images etc..*/ + contentHeight;
        
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
    if (indexPath.row != [self.dataArray count] && [self.dataArray count] > 0) {
        
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
            [cell.playerNameButton addTarget:self action:@selector(firstUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.secondPlayerNameButton addTarget:self action:@selector(secondUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        cell.playerNameButton.tag = cell.secondPlayerNameButton.tag = indexPath.row;
        ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
        
        [cell.thumbnailImageView cancelImageRequestOperation];
        cell.likeButton.tag = indexPath.row;
        cell.commentButton.tag = indexPath.row;
        
        cell.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likesCount intValue]];
        
        UIImage *buttonBackgroundImage;
        UIImage *likeImage;
        
        if ([activityStory.likedByMaster boolValue]) {
            cell.likeCountLabel.textColor = [UIColor colorWithRed:183.0f/255.0f green:158.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
            cell.likeTextLabel.text = @"Unlike";
            cell.likeTextLabel.textColor = [UIColor colorWithRed:107.0f/255.0f green:93.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
            likeImage = [UIImage imageNamed:@"LikeImageOrange"];
            buttonBackgroundImage = [[UIImage imageNamed:@"strechableBorderedImageOrange"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        } else {
            cell.likeCountLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
            cell.likeTextLabel.text = @"Like";
            cell.likeTextLabel.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
            likeImage = [UIImage imageNamed:@"LikeImage"];
            buttonBackgroundImage = [[UIImage imageNamed:@"strechableBorderedImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        }
        cell.likeButtonView.image = buttonBackgroundImage;
        cell.likeImageView.image = likeImage;
        
        cell.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.commentCount intValue]];
        [cell.resizableActivityFeedView setActivityStory:activityStory];
        
        [cell.thumbnailImageView cancelImageRequestOperation];
        cell.thumbnailImageView.image = nil;
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
        cell.backgroundColor = [UIColor clearColor];
        
        if (!self.headerInfoDownloading && self.dataDownloadInProgress == NO) {
            [self checkServerAndDeleteOld:NO];
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
    [self.tableDelegate activityFeedTableView:self didSelectRowAtIndexPath:indexPath withActivityStory:activityStory];
}

#pragma mark -

- (void)loadData
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if (self.user) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@ OR postedToUser == %@", self.user,self.user];
        //        self.dataArray = [ActivityStory MR_findAllSortedBy:@"lastUpdateDate" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
        //seting fetch limit for pagination
        NSFetchRequest *request = [ActivityStory MR_requestAllWithPredicate:predicate inContext:context];
        [request setFetchLimit:self.fetchLimit];
        //set sort descriptor
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdateDate" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        self.dataArray = [ActivityStory MR_executeFetchRequest:request inContext:context];
        
    }
    else {
        //        self.dataArray = [ActivityStory MR_findAllSortedBy:@"lastUpdateDate" ascending:NO inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        NSFetchRequest *request = [ActivityStory MR_requestAllInContext:context];
        [request setFetchLimit:self.fetchLimit];
        //set sort descriptor
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdateDate" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        self.dataArray = [ActivityStory MR_executeFetchRequest:request inContext:context];
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
                                        [self checkServerAndDeleteOld:NO];
                                    } failureBlock:^{
                                        NSLog(@"Liking failed");
                                    }];
    } else {
        [SDActivityFeedService unlikeActivityStory:activityStoryInContext
                                      successBlock:^{
                                          [self checkServerAndDeleteOld:NO];
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

- (void)firstUserNameButtonPressed:(UIButton *)sender
{
    ActivityStory *activityStory = [self.dataArray objectAtIndex:sender.tag];
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = activityStory.author;
    
    [self.tableDelegate activityFeedTableView:self
                    wantsNavigateToController:userProfileViewController];
}

- (void)secondUserNameButtonPressed:(UIButton *)sender
{
    ActivityStory *activityStory = [self.dataArray objectAtIndex:sender.tag];
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = activityStory.postedToUser;
    
    [self.tableDelegate activityFeedTableView:self
                    wantsNavigateToController:userProfileViewController];
}



@end
