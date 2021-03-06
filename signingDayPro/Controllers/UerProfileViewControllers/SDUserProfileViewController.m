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
#import "SDUserProfileOrganizationMemeberHeaderView.h"
#import "Team.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "ActivityStory.h"
#import "SDActivityFeedCellContentView.h"
#import "SDImageService.h"
#import "SDActivityFeedTableView.h"
#import "Conversation.h"
#import "SDConversationViewController.h"
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
#import "SDCommitsRostersCoachViewController.h"
#import "MediaGallery.h"
#import "SDGoogleAnalyticsService.h"
#import "SDOffersViewController.h"
#import "SDContactInfoViewController.h"
#import "SDTopSchoolsViewController.h"
#import "SDUserProfileOrganizationHeaderView.h"

#define kUserProfileHeaderHeight 360
#define kUserProfileHeaderHeightWithBuzzButtonView 450

#define kDefaultYearForCommits @"2014"


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
    if ([_currentUser.identifier isEqualToNumber:[self getMasterIdentifier]])
        _isMasterProfile = YES;
    
    self.tableView.activityFeedTableType = ACTIVITY_FEED_USERPROFILE;
    [self setupTableViewHeader];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([_currentUser.identifier isEqualToNumber:[self getMasterIdentifier]]) {
        self.screenName = @"My profile screen";
    }
    else {
        self.screenName = @"User profile screen";
    }
    
    [SDProfileService getProfileInfoForUser:self.currentUser
                            completionBlock:^{
                                [self setupHeaderView];
                            } failureBlock:nil];
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
        SDUserType userType = [self.currentUser.userTypeId intValue];
        switch (userType) {
            case SDUserTypePlayer: {
                SDUserProfilePlayerHeaderView *playerView = (SDUserProfilePlayerHeaderView *)[SDUserProfilePlayerHeaderView loadInstanceFromNib];
                playerView.delegate = self;
                playerView.buzzButtonView.delegate = self;
                playerView.slidingButtonView.delegate = self;
                playerView.slidingButtonView.userType = userType;
                
                view = playerView;
                break;
            }
            case SDUserTypeHighSchool: {
                SDUserProfileHighSchoolHeaderView *highschoolView = (SDUserProfileHighSchoolHeaderView *) [SDUserProfileHighSchoolHeaderView loadInstanceFromNib];
                highschoolView.delegate = self;
                highschoolView.buzzButtonView.delegate = self;
                highschoolView.slidingButtonView.delegate = self;
                highschoolView.slidingButtonView.userType = userType;
                
                view = highschoolView;
                break;
            }
            case SDUserTypeTeam: {
                SDUserProfileTeamHeaderView *teamView = (SDUserProfileTeamHeaderView *) [SDUserProfileTeamHeaderView loadInstanceFromNib];
                teamView.delegate = self;
                teamView.buzzButtonView.delegate = self;
                teamView.slidingButtonView.delegate = self;
                teamView.slidingButtonView.userType = userType;
                
                view = teamView;
                break;
            }
            case SDUserTypeMember: {
                SDUserProfileMemberHeaderView *memberView = (SDUserProfileMemberHeaderView *) [SDUserProfileMemberHeaderView loadInstanceFromNib];
                memberView.delegate = self;
                memberView.buzzButtonView.delegate = self;
                memberView.slidingButtonView.delegate = self;
                memberView.slidingButtonView.userType = userType;
                
                view = memberView;
                break;
            }
            case SDUserTypeCoach: {
                SDUserProfileCoachHeaderView *coachView = (SDUserProfileCoachHeaderView *) [SDUserProfileCoachHeaderView loadInstanceFromNib];
                coachView.delegate = self;
                coachView.buzzButtonView.delegate = self;
                coachView.slidingButtonView.delegate = self;
                coachView.slidingButtonView.userType = userType;

                view = coachView;
                break;
            }
            case SDUserTypeOrganization: {
                SDUserProfileOrganizationHeaderView *organizationView = (SDUserProfileOrganizationHeaderView *) [SDUserProfileOrganizationHeaderView loadInstanceFromNib];
                organizationView.delegate = self;
                organizationView.buzzButtonView.delegate = self;
                organizationView.slidingButtonView.delegate = self;
                organizationView.slidingButtonView.userType = userType;
                
                view = organizationView;
                break;
            }
            case SDUserTypeOrganizationMember: {
                SDUserProfileOrganizationMemeberHeaderView *nflpaView = (SDUserProfileOrganizationMemeberHeaderView *) [SDUserProfileOrganizationMemeberHeaderView loadInstanceFromNib];
                nflpaView.delegate = self;
                nflpaView.buzzButtonView.delegate = self;
                nflpaView.slidingButtonView.delegate = self;
                nflpaView.slidingButtonView.userType = userType;
                
                view = nflpaView;
                break;
            }
            default: {
                SDUserProfileMemberHeaderView *memberView = (SDUserProfileMemberHeaderView *) [SDUserProfileMemberHeaderView loadInstanceFromNib];
                memberView.delegate = self;
                memberView.buzzButtonView.delegate = self;
                memberView.slidingButtonView.delegate = self;
                memberView.slidingButtonView.userType = userType;
                
                view = memberView;
                break;
            }
        }
        
        self.headerView = view;
        self.tableView.headerInfoDownloading = YES;
        [self setupHeaderView];
        self.tableView.customHeaderView = self.headerView;
    }
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
                [self playVideoWithMediaFileUrlString:activityStory.mediaUrl];
            }
        }
    }
}

- (void)showImageViewWithActivityStory:(ActivityStory *)activityStory
{
    SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame andImage:activityStory.mediaUrl];
    [imageEnlargemenetView presentImageViewInView:self.navigationController.view];
}

- (void)playVideoWithMediaFileUrlString:(NSString *)urlString
{
    if ([urlString rangeOfString:@"signingday"].location == NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else {
        //signingday link
        NSURL *url = [NSURL URLWithString:urlString];
        [self playVideoWithUrl:url];
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

- (void)headerView:(id)headerView didSelectSchoolUser:(User *)schoolUser
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = schoolUser;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
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
    
    [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Post_In_User_Profile_Selected"];
}

- (void)messageButtonPressedInButtonView:(SDBuzzButtonView *)buzzButtonView
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Conversation *conversation = [Conversation MR_createInContext:context];
    [conversation addUsersObject:self.currentUser];
    [context MR_saveToPersistentStoreAndWait];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MessagesStoryboard"
                                                         bundle:nil];
    SDConversationViewController *conversationViewController = (SDConversationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
    conversationViewController.conversation = conversation;
    conversationViewController.isNewConversation = YES;
    
    [self.navigationController pushViewController:conversationViewController animated:YES];
    
    [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Private_Message_In_User_Profile_Selected"];
}

#pragma mark - SlidingViewButton Delegate

- (void)userProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
                      isNowFollowing:(BOOL)isFollowing
{
    if (isFollowing) {
        [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Follow_Button_Selected_Profile_View"];
        [SDFollowingService followUserWithIdentifier:self.currentUser.identifier
                                 withCompletionBlock:^{
                                 } failureBlock:^{
                                     
                                 }];
        
    } else {
        [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Unfollow_Button_Selected_Profile_View"];
        [SDFollowingService unfollowUserWithIdentifier:self.currentUser.identifier
                                   withCompletionBlock:^{
                                       
                                   } failureBlock:^{
                                       
                                   }];
    }
}

- (void)staffButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    NSString *currentUserIdentifier = [self.currentUser.identifier stringValue];
    SDCommitsRostersCoachViewController *rosterViewController = [[SDCommitsRostersCoachViewController alloc] initWithNibName:@"SDCommitsRostersCoachViewController" bundle:[NSBundle mainBundle]];
    rosterViewController.userIdentifier = currentUserIdentifier;
    rosterViewController.controllerType = CONTROLLER_TYPE_COACHINGSTAFF;
    [self.navigationController pushViewController:rosterViewController animated:YES];
}

- (void)photosButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    [self pushCollectionViewControllerWithGalleryType:SDGalleryTypePhotos];
}


- (void)videosButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    [self pushCollectionViewControllerWithGalleryType:SDGalleryTypeVideos];
}

- (void)bioButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDBioViewController *bioViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"BioViewController"];
    bioViewController.currentUser = self.currentUser;
    [self.navigationController pushViewController:bioViewController animated:YES];
}

- (void)keyAttributesPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    NSString *currentUserIdentifier = [self.currentUser.identifier stringValue];
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDKeyAttributesViewController *keyAttributesViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"KeyAttributesViewController"];
    keyAttributesViewController.userIdentifierString = currentUserIdentifier;
    [self.navigationController pushViewController:keyAttributesViewController animated:YES];
}

- (void)offersPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    SDOffersViewController *offersViewController = [[SDOffersViewController alloc] initWithNibName:@"SDBaseViewController" bundle:nil];
    offersViewController.currentUser = self.currentUser;
    
    [self.navigationController pushViewController:offersViewController animated:YES];
}

- (void)rosterPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    NSString *currentUserIdentifier = [self.currentUser.identifier stringValue];
    SDCommitsRostersCoachViewController *rosterViewController = [[SDCommitsRostersCoachViewController alloc] initWithNibName:@"SDCommitsRostersCoachViewController" bundle:[NSBundle mainBundle]];
    rosterViewController.userIdentifier = currentUserIdentifier;
    rosterViewController.controllerType = CONTROLLER_TYPE_ROSTERS;
    [self.navigationController pushViewController:rosterViewController animated:YES];
}

- (void)commitsPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    NSString *currentUserIdentifier = [self.currentUser.identifier stringValue];
    SDCommitsRostersCoachViewController *commitsViewController = [[SDCommitsRostersCoachViewController alloc] initWithNibName:@"SDCommitsRostersCoachViewController" bundle:[NSBundle mainBundle]];
    commitsViewController.userIdentifier = currentUserIdentifier;
    commitsViewController.controllerType = CONTROLLER_TYPE_COMMITS;
    commitsViewController.yearString = self.currentUser.theTeam.teamClass;
    [self.navigationController pushViewController:commitsViewController animated:YES];
}

- (void)contactsPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDContactInfoViewController *contactInfoViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"ContactInfoViewController"];
    contactInfoViewController.currentUser = self.currentUser;
    [self.navigationController pushViewController:contactInfoViewController animated:YES];
}

- (void)topSchoolsPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
{
    SDTopSchoolsViewController *topSchoolsViewController = [[SDTopSchoolsViewController alloc] initWithNibName:@"SDBaseViewController" bundle:nil];
    topSchoolsViewController.currentUser = self.currentUser;
    
    [self.navigationController pushViewController:topSchoolsViewController animated:YES];
}

#pragma mark -

- (void)pushCollectionViewControllerWithGalleryType:(SDGalleryType)galleryType
{
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDCollectionViewController *collectionViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    collectionViewController.galleryType = galleryType;
    collectionViewController.user = self.currentUser;
    [self.navigationController pushViewController:collectionViewController animated:YES];
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

- (void)followingUpdated
{
    [self.headerView updateFollowingInfo];
}

@end
