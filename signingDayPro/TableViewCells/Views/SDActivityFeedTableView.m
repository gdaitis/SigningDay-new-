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
#import "SDGoogleAnalyticsService.h"
#import "SDUserProfileViewController.h"
#import "UIView+NibLoading.h"
#import "SDActivityFeedForumCell.h"
#import "NSAttributedString+DTCoreText.h"

#define kOffsetHeaderViewSize 6
#define kMinimalCustomTableHeaderSize 369

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
        
        //    NSString *postText = @"<p>reply</p>";
//        NSString *postText = @"<p><div class=\"quote-header\"></div><div class=\"quote-mycustom\"><blockquote class=\"quote\"><div class=\"quote-user\">Lukas</div><div class=\"quote-content\"><p>reply</p><p></p></div></blockquote></div><div class=\"quote-footer\"></div></p><p>Quote test</p>";
//        
//        NSAttributedString *attributedString = [SDUtils buildDTCoreTextStringForSigningdayWithHTMLText:postText];
//        CGSize attributedTextSize = [attributedString attributedStringSizeForWidth:kSDActivityFeedForumCellPostLabelWidth];
//        int result = 110/*buttons images etc..*/ + attributedTextSize.height;
//        
//        return result;

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
        
        ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
        NSString *cellIdentifier = @"ActivityFeedCellId";
        SDActivityFeedCell *cell = (SDActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            
            cell = (id)[SDActivityFeedCell loadInstanceFromNib];
            [cell.playerNameButton addTarget:self action:@selector(firstUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.secondPlayerNameButton addTarget:self action:@selector(secondUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        [cell setupCellWithActivityStory:activityStory atIndexPath:indexPath];
        
        return cell;
        
//        NSString *cellIdentifier = @"ActivityFeedForumCellId";
//        SDActivityFeedForumCell *cell = (SDActivityFeedForumCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (!cell) {
//            
//            cell = (id)[SDActivityFeedForumCell loadInstanceFromNib];
//            [cell.userNameButton addTarget:self action:@selector(firstUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.replyButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//            cell.backgroundColor = [UIColor clearColor];
//        }
//
//        [cell setupCellWithActivityStory:activityStory atIndexPath:indexPath];
//        
//        return cell;
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
        
        if (!self.headerInfoDownloading && self.dataDownloadInProgress == NO)
            [self checkServerAndDeleteOld:NO];
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.activityFeedTableType == ACTIVITY_FEED_USERPROFILE)
    {
        return self.customHeaderView;
    }
    else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kOffsetHeaderViewSize)];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.activityFeedTableType == ACTIVITY_FEED_USERPROFILE)
    {
        int result = (self.customHeaderView.frame.size.height < kMinimalCustomTableHeaderSize) ? kMinimalCustomTableHeaderSize : self.customHeaderView.frame.size.height;
        return result;
    }
    else {
        return kOffsetHeaderViewSize;
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
        
        //seting fetch limit for pagination
        NSFetchRequest *request = [ActivityStory MR_requestAllWithPredicate:predicate inContext:context];
        [request setFetchLimit:self.fetchLimit];

        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUpdateDate" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        self.dataArray = [ActivityStory MR_executeFetchRequest:request inContext:context];
        
    }
    else {
        
        NSFetchRequest *request = [ActivityStory MR_requestAllInContext:context];
        [request setFetchLimit:self.fetchLimit];

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
        [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Like_Selected_Activity_Feed"];
    } else {
        [SDActivityFeedService unlikeActivityStory:activityStoryInContext
                                      successBlock:^{
                                          [self checkServerAndDeleteOld:NO];
                                      } failureBlock:^{
                                          NSLog(@"Unliking failed");
                                      }];
        [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Unlike_Selected_Activity_Feed"];
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
