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
#import "SDKeyAttributesViewController.h"
#import "SDBuzzSomethingViewController.h"
#import "SDFollowingService.h"
#import "SDBioViewController.h"
#import "SDCollectionViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SDImageEnlargementView.h"
#import "SDYoutubePlayerViewController.h"
#import "SDBaseProfileHeaderView.h"
#import "WebPreview.h"

#define kUserProfileHeaderHeight 360
#define kUserProfileHeaderHeightWithBuzzButtonView 450


@interface SDUserProfileViewController () <NSFetchedResultsControllerDelegate, SDActivityFeedTableViewDelegate, SDUserProfileSlidingButtonViewDelegate, SDBuzzButtonViewDelegate, SDModalNavigationControllerDelegate>
{
    BOOL _isMasterProfile;
}

@property (nonatomic, strong) IBOutlet SDActivityFeedTableView *tableView;
@property (atomic, strong) NSArray *dataArray;
@property (nonatomic, strong) SDBaseProfileHeaderView *headerView;    //may be different depending on user

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
    self.tableView.fetchLimit = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    self.tableView.user = self.currentUser;
    self.tableView.tableDelegate = self;
    [self setupTableViewHeader];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [SDProfileService getProfileInfoForUser:self.currentUser
                            completionBlock:^{
                                [self setupHeaderView];
                            } failureBlock:nil];
    
    [SDProfileService getPhotosForUser:self.currentUser
                       completionBlock:nil
                          failureBlock:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingUpdated) name:@"FollowingUpdated" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FollowingUpdated" object:nil];
}

#pragma mark - refreshing

- (void)checkServer
{
    self.tableView.activityStoryCount = 0;
    self.tableView.fetchLimit = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    [self.tableView checkServerAndDeleteOld:NO];
    
    [SDProfileService getProfileInfoForUser:self.currentUser
                            completionBlock:^{
                                [self setupHeaderView];
                            } failureBlock:^{
                                //
                            }];
}

#pragma mark - TableView datasource

- (void)setupTableViewHeader
{
    if (!self.headerView) {
        
        // Load headerview
        id view = nil;
        switch ([self.currentUser.userTypeId intValue]) {
            case SDUserTypePlayer:
            {
                SDUserProfilePlayerHeaderView *playerView = (SDUserProfilePlayerHeaderView *)[SDUserProfilePlayerHeaderView loadInstanceFromNib];
                playerView.delegate = self;
                playerView.buzzButtonView.delegate = self;
                playerView.slidingButtonView.delegate = self;
                [playerView.slidingButtonView.changingButton setImage:[UIImage imageNamed:@"UserProfileKeyAttributesButton.png"] forState:UIControlStateNormal];
                playerView.slidingButtonView.keyAttributesLabel.text = @"Key Attributes";
                view = playerView;
                break;
            }
            case SDUserTypeHighSchool:
            {
                SDUserProfileHighSchoolHeaderView *highschoolView = (SDUserProfileHighSchoolHeaderView *) [SDUserProfileHighSchoolHeaderView loadInstanceFromNib];
                highschoolView.delegate = self;
                highschoolView.buzzButtonView.delegate = self;
                highschoolView.slidingButtonView.delegate = self;
                [highschoolView.slidingButtonView.changingButton setImage:[UIImage imageNamed:@"UserProfileProspectsButton.png"] forState:UIControlStateNormal];
                highschoolView.slidingButtonView.keyAttributesLabel.text = @"Prospects";
                view = highschoolView;
                break;
            }
            case SDUserTypeTeam:
            {
                SDUserProfileTeamHeaderView *teamView = (SDUserProfileTeamHeaderView *) [SDUserProfileTeamHeaderView loadInstanceFromNib];
                teamView.delegate = self;
                teamView.buzzButtonView.delegate = self;
                teamView.slidingButtonView.delegate = self;
                [teamView.slidingButtonView.changingButton setImage:[UIImage imageNamed:@"UserProfileCommitsButton.png"] forState:UIControlStateNormal];
                teamView.slidingButtonView.keyAttributesLabel.text = @"Commits";
                view = teamView;
                break;
            }
            case SDUserTypeMember:
            {
                SDUserProfileMemberHeaderView *memberView = (SDUserProfileMemberHeaderView *) [SDUserProfileMemberHeaderView loadInstanceFromNib];
                memberView.delegate = self;
                memberView.buzzButtonView.delegate = self;
                memberView.slidingButtonView.delegate = self;
                [memberView.slidingButtonView.changingButton removeFromSuperview];
                [memberView.slidingButtonView.keyAttributesLabel removeFromSuperview];
                view = memberView;
                break;
            }
            case SDUserTypeCoach:
            {
                SDUserProfileCoachHeaderView *coachView = (SDUserProfileCoachHeaderView *) [SDUserProfileCoachHeaderView loadInstanceFromNib];
                coachView.delegate = self;
                coachView.buzzButtonView.delegate = self;
                coachView.slidingButtonView.delegate = self;
                [coachView.slidingButtonView.changingButton setImage:[UIImage imageNamed:@"UserProfileCommitsButton.png"] forState:UIControlStateNormal];
                coachView.slidingButtonView.keyAttributesLabel.text = @"Commits";
                view = coachView;
                break;
            }
            default:
            {
                SDUserProfileMemberHeaderView *memberView = (SDUserProfileMemberHeaderView *) [SDUserProfileMemberHeaderView loadInstanceFromNib];
                memberView.delegate = self;
                memberView.buzzButtonView.delegate = self;
                memberView.slidingButtonView.delegate = self;
                [memberView.slidingButtonView.changingButton setImage:[UIImage imageNamed:@"UserProfileKeyAttributesButton.png"] forState:UIControlStateNormal];
                view = memberView;
                break;
            }
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
    [self.tableView reloadData];
}

#pragma mark - SDActivityFeedTableView delegate methods

- (void)activityFeedTableView:(SDActivityFeedTableView *)activityFeedTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withActivityStory:(ActivityStory *)activityStory
{
    if (activityStory.webPreview) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:activityStory.webPreview.link]];
    }
    else {
        if (activityStory.mediaType) {
            if ([activityStory.mediaType isEqualToString:@"photos"]) {
                //photos
                //show enlarged image view
                [self showImageViewWithActivityStory:activityStory];
            }
            else {
                //videos
                [self playVideoWithActivityStory:activityStory];
            }
        }
    }
}

- (void)showImageViewWithActivityStory:(ActivityStory *)activityStory
{
    SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame andImage:activityStory.mediaUrl];
    [imageEnlargemenetView presentImageViewInView:self.navigationController.view];
}

- (void)playVideoWithActivityStory:(ActivityStory *)activityStory
{
    if ([activityStory.mediaUrl rangeOfString:@"youtube"].location == NSNotFound) {
        NSURL *url = [NSURL URLWithString:activityStory.mediaUrl];
        [self playVideoWithUrl:url];
    }
    else {
        //youtube link
        [self showYoutubePlayerWithUrlString:activityStory.mediaUrl];
    }
}

- (void)showYoutubePlayerWithUrlString:(NSString *)url
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)playVideoWithUrl:(NSURL *)url
{
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] init];
    [player.moviePlayer setContentURL:url];
    player.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [player.view setFrame:self.view.bounds];
    [player.moviePlayer prepareToPlay];
    
    [self presentMoviePlayerViewControllerAnimated:player];
    [player.moviePlayer play];
}

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

#pragma mark - SlidingViewButton Delegate

- (void)changingButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    //this button is different depending on types of user, different actions should be taken
    
    switch ([self.currentUser.userTypeId intValue]) {
        case SDUserTypePlayer:
        {
            UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                                bundle:nil];
            SDKeyAttributesViewController *keyAttributesViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"KeyAttributesViewController"];
            [self.navigationController pushViewController:keyAttributesViewController animated:YES];
            
            break;
        }
        case SDUserTypeHighSchool:

            break;
        case SDUserTypeTeam:

            break;
        case SDUserTypeMember:

            break;
        case SDUserTypeCoach:

            break;
        default:

            break;
    }
}

- (void)photosButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
#warning add user related stuff
    SDCollectionViewController *collectionViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    [self.navigationController pushViewController:collectionViewController animated:YES];
}

- (void)videosButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
#warning add user related stuff
    
    SDCollectionViewController *collectionViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    [self.navigationController pushViewController:collectionViewController animated:YES];
}

- (void)bioButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDBioViewController *bioViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"BioViewController"];
    bioViewController.currentUser = self.currentUser;
    [self.navigationController pushViewController:bioViewController animated:YES];
}

- (void)userProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
                      isNowFollowing:(BOOL)isFollowing
{
#warning delegate moved, check for bugs!!
    if (isFollowing) {
        [SDFollowingService followUserWithIdentifier:self.currentUser.identifier
                                 withCompletionBlock:^{
                                 } failureBlock:^{
                                     
                                 }];
        
    } else {
        [SDFollowingService unfollowUserWithIdentifier:self.currentUser.identifier
                                   withCompletionBlock:^{
                                       
                                   } failureBlock:^{
                                       
                                   }];
    }
}

#pragma mark - SDModalNavigationController myDelegate methods

- (void)modalNavigationControllerWantsToClose:(SDModalNavigationController *)modalNavigationController
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self checkServer];
                             }];
}

#pragma mark - NSNotificationCenter

-(void)followingUpdated
{
    [self.headerView updateFollowingInfo];
}

@end
