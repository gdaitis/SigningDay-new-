//
//  SDActivityStoryViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 8/29/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityStoryViewController.h"
#import "ActivityStory.h"
#import "User.h"
#import "SDUtils.h"
#import "AFNetworking.h"
#import "SDActivityFeedCellContentView.h"
#import "SDUserProfileViewController.h"
#import "SDImageEnlargementView.h"

#import "SDYoutubePlayerViewController.h"
#import "SDActivityFeedCell.h"

#import "SDCommentsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SDActivityFeedService.h"


@interface SDActivityStoryViewController ()

@property (strong, nonatomic) MPMoviePlayerViewController *player;

@end

@implementation SDActivityStoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl removeFromSuperview];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int contentHeight = [SDUtils heightForActivityStory:self.activityStory];
    int result = 119/*buttons images etc..*/ + contentHeight;
    
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
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
        [cell.playerNameButton addTarget:self action:@selector(firstUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.secondPlayerNameButton addTarget:self action:@selector(secondUserNameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.containerView.image = nil;
    }
    
    cell.playerNameButton.tag = cell.secondPlayerNameButton.tag = indexPath.row;
    
    [cell.thumbnailImageView cancelImageRequestOperation];
    cell.likeButton.tag = indexPath.row;
    cell.commentButton.tag = indexPath.row;
    
    cell.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[self.activityStory.likesCount intValue]];
    
    UIImage *buttonBackgroundImage;
    UIImage *likeImage;
    
    if ([self.activityStory.likedByMaster boolValue]) {
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
    
    cell.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[self.activityStory.commentCount intValue]];
    [cell.resizableActivityFeedView setActivityStory:self.activityStory];
    
    if ([self.activityStory.author.avatarUrl length] > 0) {
        [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:self.activityStory.author.avatarUrl]];
    }
    
    cell.postDateLabel.text = [SDUtils formatedTimeForDate:self.activityStory.createdDate];
    [cell setupNameLabelForActivityStory:self.activityStory];
    
    return cell;
    
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.activityStory.mediaType) {
        if ([self.activityStory.mediaType isEqualToString:@"photos"]) {
            //photos
            //show enlarged image view
            [self showImageView];
        }
        else {
            //videos
            [self playVideo];
        }
    }
}

#pragma mark - like/comment button pressed

- (void)likeButtonPressed:(UIButton *)sender
{
    NSManagedObjectContext *activityStoryContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    BOOL likeStatus;
    int likeInt;
    if ([self.activityStory.likedByMaster boolValue]) {
        likeStatus = NO;
        likeInt = -1;
    } else {
        likeStatus = YES;
        likeInt = +1;
    }
    self.activityStory.likedByMaster = [NSNumber numberWithBool:likeStatus];
    NSNumber *newNumberOfLikes = [NSNumber numberWithInt:([self.activityStory.likesCount integerValue] + likeInt)];
    self.activityStory.likesCount = newNumberOfLikes;
    
    [activityStoryContext MR_saveOnlySelfAndWait];
    
    if (likeStatus) {
        [SDActivityFeedService likeActivityStory:self.activityStory
                                    successBlock:^{

                                    } failureBlock:^{
                                        NSLog(@"Liking failed");
                                    }];
    } else {
        [SDActivityFeedService unlikeActivityStory:self.activityStory
                                      successBlock:^{
                                      } failureBlock:^{
                                          NSLog(@"Unliking failed");
                                      }];
    }
    [self.tableView reloadData];
}

- (void)commentButtonPressed:(UIButton *)sender
{
    UIStoryboard *commentsViewStoryboard = [UIStoryboard storyboardWithName:@"CommentsViewStoryboard"
                                                                     bundle:nil];
    SDCommentsViewController *commentsViewController = [commentsViewStoryboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    commentsViewController.activityStory = self.activityStory;
    
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

#pragma mark - View Setup

- (void)firstUserNameButtonPressed:(id)sender
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = self.activityStory.author;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)secondUserNameButtonPressed:(id)sender
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = self.activityStory.postedToUser;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)showImageView
{
    SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame andImage:self.activityStory.mediaUrl];
    [imageEnlargemenetView presentImageViewInView:self.navigationController.view];
}

- (void)playVideo
{
    if ([self.activityStory.mediaUrl rangeOfString:@"youtube"].location == NSNotFound) {
        NSURL *url = [NSURL URLWithString:self.activityStory.mediaUrl];
        [self playVideoWithUrl:url];
    }
    else {
        //youtube link
        [self showYoutubePlayerWithUrlString:self.activityStory.mediaUrl];
    }
}

- (void)showYoutubePlayerWithUrlString:(NSString *)url
{
    SDYoutubePlayerViewController *youtubePlayerViewController = [[SDYoutubePlayerViewController alloc] initWithNibName:@"SDYoutubePlayerViewController" bundle:[NSBundle mainBundle]];
    youtubePlayerViewController.urlLink = url;
    
    [self.navigationController pushViewController:youtubePlayerViewController animated:YES];
}

- (void)playVideoWithUrl:(NSURL *)url
{
    self.player = [[MPMoviePlayerViewController alloc] init];
    [self.player.moviePlayer setContentURL:url];
    self.player.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [self.player.view setFrame:self.view.bounds];
    [self.player.moviePlayer prepareToPlay];
    
    [self presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];
}

@end
