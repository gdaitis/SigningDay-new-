//
//  SDNavigationController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/27/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNavigationController.h"
#import "IIViewDeckController.h"
#import "SDMessageViewController.h"
#import "SDConversationViewController.h"
#import "SDUserProfileViewController.h"
#import "SDFollowingService.h"
#import "SDBaseViewController.h"
#import "SDNewConversationViewController.h"
#import "SDCustomNavigationToolbarView.h"
#import "UIView+NibLoading.h"
#import "SDBadgeView.h"
#import "SDNotificationsService.h"
#import "SDActivityStoryViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface SDNavigationController () <SDCustomNavigationToolbarViewDelegate>

//properties for presenting toolbar menus on navigating back
@property (nonatomic, strong) UIViewController *lastControllerForToolbarItems;
@property (nonatomic, assign) BarButtonType lastSelectedType;
@property (nonatomic, assign) BOOL showFilterButton;
@property (nonatomic, assign) BOOL filterViewVisible;
@property (nonatomic, assign) BOOL navigationInProgress;

@end

@implementation SDNavigationController

- (UIView *)contentView
{
    if (!_contentView) {
        
        int widht = self.view.frame.size.width;
        int toptoolbarHeight = self.topToolBar.frame.size.height;
        int height = self.view.frame.size.height - toptoolbarHeight;
        _backButtonVisibleIfNeeded = NO;
        
        UIView *contView = [[UIView alloc] initWithFrame:CGRectMake(0, -height, widht, height)];
        _contentView = contView;
        
    }
    return _contentView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.delegate = self;
    
    _selectedMenuType = BARBUTTONTYPE_NONE;
    _backButtonVisibleIfNeeded = YES;
    
    //creates and adds buttons to the top toolbar
    [self setupToolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)revealMenu:(id)sender
{
    //opens side menu
    [self.viewDeckController toggleLeftViewAnimated:YES];
}

#pragma mark - Server

- (void)checkServer
{
    [SDNotificationsService getCountOfUnreadNotificationsWithSuccessBlock:^(NSDictionary *unreadNotificationsCountDictionary) {
        NSInteger *notificationsNumber = [[unreadNotificationsCountDictionary valueForKey:SDNotificationsServiceCountOfUnreadNotifications] integerValue];
        NSInteger *messagesNumber = [[unreadNotificationsCountDictionary valueForKey:SDNotificationsServiceCountOfUnreadConversations] integerValue];
        NSInteger *followersNumber = [[unreadNotificationsCountDictionary valueForKey:SDNotificationsServiceCountOfUnreadFollowers] integerValue];
        [self setupBadgesWithNotificationsNumber:notificationsNumber
                                  messagesNumber:messagesNumber
                                 followersNumber:followersNumber];
    } failureBlock:^{
        [self setupBadgesWithNotificationsNumber:0
                                  messagesNumber:0
                                 followersNumber:0];
    }];
}

#pragma mark - Toolbar

- (void)setupToolbar
{
    //creating and adding toolbar
    float y = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 20 : 0;
    if (!self.topToolBar) {
        SDCustomNavigationToolbarView *toolbarView = (id)[SDCustomNavigationToolbarView loadInstanceFromNib];
        toolbarView.delegate = self;
        self.topToolBar = toolbarView;
        self.topToolBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kTopToolbarHeight+y);
        [self.view addSubview:_topToolBar];
    }
    
    [self setToolbarButtons];
}

#pragma mark - Navigation

- (void)rememberCurrentControllerForButtonType:(BarButtonType)barButtonType
{
    self.lastControllerForToolbarItems = [self.viewControllers lastObject];
    self.lastSelectedType = barButtonType;
}
- (void)forgetLastController
{
    self.lastControllerForToolbarItems = nil;
    self.lastSelectedType = BARBUTTONTYPE_NONE;
}

- (void)popViewController
{
    [self checkServer];
    if (!self.navigationInProgress) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self popViewControllerAnimated:YES];
            [self setToolbarButtons];
        });
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self checkServer];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [super pushViewController:viewController animated:animated];
        [self.view bringSubviewToFront:_topToolBar];
        [self setToolbarButtons];
    });
}

- (void)setToolbarButtons
{
    //set left button actions
    
    UIImage *leftButtonImage = ([self.viewControllers count] > 1 && _backButtonVisibleIfNeeded) ? [UIImage imageNamed:@"MenuButtonBack.png"] : [UIImage imageNamed:@"MenuButton.png"];
    [self.topToolBar setLeftButtonImage:leftButtonImage];
    
    //set midle button actions
    self.topToolBar.notificationButton.selected = (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) ? YES : NO;
    self.topToolBar.messagesButton.selected = (_selectedMenuType == BARBUTTONTYPE_CONVERSATIONS)? YES : NO;
    self.topToolBar.followersButton.selected = (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) ? YES : NO;
    self.topToolBar.rightButton.selected = (self.filterViewVisible) ? YES : NO;
    
    //check is filter button needed
    if (self.showFilterButton) {
        [self.topToolBar setrightButtonImage:[UIImage imageNamed:@"LandingPageFilterButton.png"]];
        self.topToolBar.rightButton.hidden = NO;
    }
    else {
        self.topToolBar.rightButton.hidden = YES;
    }
    
}

- (void)hideKeyboardsOfUIResponders
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDKeyboardShouldHideNotification
                                                        object:nil];
}

#pragma mark - Setting badges

- (void)setupBadgesWithNotificationsNumber:(NSInteger)notificationsNumber
                            messagesNumber:(NSInteger)messagesNumber
                           followersNumber:(NSInteger)followersNumber
{
    for (UIView *subiew in self.topToolBar.subviews) {
        if ([subiew isKindOfClass:[SDBadgeView class]])
            [subiew removeFromSuperview];
    }
    SDBadgeView *notificationsBadge = [self createBadgeWithNumber:notificationsNumber
                                                 forToolbarButton:self.topToolBar.notificationButton
                                                     withSelector:@selector(notificationsSelected)];
    SDBadgeView *messagesBadge = [self createBadgeWithNumber:messagesNumber
                                            forToolbarButton:self.topToolBar.messagesButton
                                                withSelector:@selector(conversationsSelected)];
    SDBadgeView *followersBadge = [self createBadgeWithNumber:followersNumber
                                             forToolbarButton:self.topToolBar.followersButton
                                                 withSelector:@selector(followersSelected)];
    [self.topToolBar addSubview:notificationsBadge];
    [self.topToolBar addSubview:messagesBadge];
    [self.topToolBar addSubview:followersBadge];
}

- (SDBadgeView *)createBadgeWithNumber:(NSInteger)badgeNumber
                      forToolbarButton:(UIButton *)toolbarButton
                          withSelector:(SEL)selector
{
    SDBadgeView *badgeView = [[SDBadgeView alloc] init];
    badgeView.badgeCountNumber = badgeNumber;
    badgeView.center = CGPointMake(toolbarButton.frame.origin.x + toolbarButton.frame.size.width - badgeView.frame.size.width / 3,
                                   toolbarButton.frame.origin.y + badgeView.frame.size.height / 3);
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:selector];
    [badgeView addGestureRecognizer:gestureRecognizer];
    return badgeView;
}

#pragma mark - Toolbar button actions

- (void)notificationsSelected
{
    if (_selectedMenuType == BARBUTTONTYPE_CONVERSATIONS) {
        [self hideFollowersAndRemoveContentView:NO];
        [self showNotifications];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) {
        [self hideFollowersAndRemoveContentView:NO];
        [self showNotifications];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) {
        [self hideNotificationsAndRemoveContentView:YES];
    }
    else {
//        btn.selected = YES;
        [self showNotifications];
    }
    [self setToolbarButtons];
}

- (void)conversationsSelected
{
    if (_selectedMenuType == BARBUTTONTYPE_CONVERSATIONS) {
        [self hideConversationsAndRemoveContentView:YES];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) {
        [self hideFollowersAndRemoveContentView:NO];
        [self showConversations];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) {
        [self hideNotificationsAndRemoveContentView:NO];
        [self showConversations];
    }
    else {
//        btn.selected = YES;
        [self showConversations];
    }
    [self setToolbarButtons];
}

- (void)followersSelected
{
    if (_selectedMenuType == BARBUTTONTYPE_CONVERSATIONS) {
        [self hideConversationsAndRemoveContentView:NO];
        [self showFollowers];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) {
        [self hideFollowersAndRemoveContentView:YES];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) {
        [self hideNotificationsAndRemoveContentView:NO];
        [self showFollowers];
    }
    else {
        [self showFollowers];
    }
    [self setToolbarButtons];
}


- (void)filterButtonSelected
{
    NSDictionary *dictionary = nil;
    
    if (self.filterViewVisible) {
        dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hideFilterView", nil];
        self.filterViewVisible = NO;
    }
    else {
        dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"hideFilterView", nil];
        self.filterViewVisible = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFilterButtonPressedNotification object:nil userInfo:dictionary];
    [self setToolbarButtons];
}

- (void)filterViewBecameHidden
{
    self.filterViewVisible = NO;
    [self setToolbarButtons];
}

- (void)addFilterButton
{
    self.showFilterButton = YES;
    [self setToolbarButtons];
}

- (void)removeFilterButton
{
    self.showFilterButton = NO;
    [self setToolbarButtons];
}

#pragma mark - Displaying top menu

- (void)showNotifications
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Notifications screen"
                                                      forKey:kGAIScreenName] build]];
    
    _selectedMenuType = BARBUTTONTYPE_NOTIFICATIONS;
    if (!_notificationVC) {
        SDNotificationViewController *notificationVC = [[SDNotificationViewController alloc] init];
        notificationVC.delegate = self;
        notificationVC.view.frame = self.contentView.bounds;
        
        self.notificationVC = notificationVC;
    }
    
    if (!_contentViewVisible) {
        [self.view addSubview:self.contentView];
        [self addTriangleArrowForBtnType:BARBUTTONTYPE_NOTIFICATIONS];
    }
    else {
        [self clearContentView];
        [self animateTriangleArrowToBtnWithType:BARBUTTONTYPE_NOTIFICATIONS];
    }
    
    [self.contentView addSubview:_notificationVC.view];
    [self.view bringSubviewToFront:_topToolBar];
    
    if (!_contentViewVisible) {
        _contentViewVisible = YES;
        [UIView animateWithDuration:0.25f animations:^{
            _contentView.frame = CGRectMake(0, _topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
        } completion:^(__unused BOOL finished) {
        }];
    }
    [_notificationVC loadInfo];
}

- (void)hideNotificationsAndRemoveContentView:(BOOL)removeContentView
{
    if (_notificationVC) {
        if (removeContentView) {
            [self hideAndRemoveContentViewAnimated];
        }
        else {
            [_notificationVC.view removeFromSuperview];
        }
    }
}

- (void)showConversations
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Conversations screen"
                                                      forKey:kGAIScreenName] build]];
    
    _selectedMenuType = BARBUTTONTYPE_CONVERSATIONS;
    if (!_messageVC) {
        SDMessageViewController *sdmessageVC = [[SDMessageViewController alloc] init];
        sdmessageVC.delegate = self;
        sdmessageVC.view.frame = self.contentView.bounds;
        
        self.messageVC = sdmessageVC;
    }
    
    if (!_contentViewVisible) {
        [self.view addSubview:self.contentView];
        [self addTriangleArrowForBtnType:BARBUTTONTYPE_CONVERSATIONS];
    }
    else {
        [self clearContentView];
        [self animateTriangleArrowToBtnWithType:BARBUTTONTYPE_CONVERSATIONS];
    }
    
    [self.contentView addSubview:_messageVC.view];
    [self.view bringSubviewToFront:_topToolBar];
    
    if (!_contentViewVisible) {
        _contentViewVisible = YES;
        [UIView animateWithDuration:0.25f animations:^{
            _contentView.frame = CGRectMake(0, _topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
        } completion:^(__unused BOOL finished) {
        }];
    }
    [_messageVC loadInfo];
}

- (void)hideConversationsAndRemoveContentView:(BOOL)removeContentView
{
    if (_messageVC) {
        if (removeContentView) {
            [self hideAndRemoveContentViewAnimated];
        }
        else {
            [_messageVC.view removeFromSuperview];
        }
    }
}

- (void)showFollowers
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Followers screen"
                                                      forKey:kGAIScreenName] build]];
    
    [SDFollowingService removeFollowing:YES andFollowed:YES];
    _selectedMenuType = BARBUTTONTYPE_FOLLOWERS;
    if (!_followingVC) {
        SDFollowingViewController *sdfollowingVC = [[SDFollowingViewController alloc] init];
        sdfollowingVC.view.frame = self.contentView.bounds;
        sdfollowingVC.delegate = self;
        [SDFollowingService removeFollowing:YES andFollowed:YES];
        self.followingVC = sdfollowingVC;
    }
    
    if (!_contentViewVisible) {
        [self.view addSubview:self.contentView];
        [self addTriangleArrowForBtnType:BARBUTTONTYPE_FOLLOWERS];
    }
    else {
        [self clearContentView];
        [self animateTriangleArrowToBtnWithType:BARBUTTONTYPE_FOLLOWERS];
    }
    
    [self.contentView addSubview:_followingVC.view];
    [self.view bringSubviewToFront:_topToolBar];
    
    if (!_contentViewVisible) {
        _contentViewVisible = YES;
        [UIView animateWithDuration:0.25f animations:^{
            _contentView.frame = CGRectMake(0, _topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
        } completion:^(__unused BOOL finished) {
        }];
    }
    [_followingVC loadInfo];
}

- (void)hideFollowersAndRemoveContentView:(BOOL)removeContentView
{
    if (_followingVC) {
        if (removeContentView) {
            [self hideAndRemoveContentViewAnimated];
        }
        else {
            [_followingVC.view removeFromSuperview];
        }
    }
}

- (void)hideAndRemoveContentViewAnimated
{
    _contentViewVisible = NO;
    _selectedMenuType = BARBUTTONTYPE_NONE;
    _backButtonVisibleIfNeeded = YES;
    [UIView animateWithDuration:0.25f animations:^{
        _contentView.frame = CGRectMake(0, -self.view.bounds.size.height+_topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
    } completion:^(__unused BOOL finished) {
        [self removeTriangleArrow];
        [_contentView removeFromSuperview];
        _contentView = nil;
    }];
    [self setToolbarButtons];
}

- (void)addTriangleArrowForBtnType:(BarButtonType)barBtnType
{
    //removes white triangle arrow indicating which barbutton item is selected
    [self removeTriangleArrow];
    
    UIImageView *triangleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ToolbarItemSelectedArrow.png"]];
    triangleImgView.tag = kTriangleViewTag;
    CGRect frame = triangleImgView.frame;
    
    //add triangle arrow to the toolbar in specific place
    switch (barBtnType) {
        case BARBUTTONTYPE_NOTIFICATIONS:
            frame.origin.x = 92;
            break;
        case BARBUTTONTYPE_CONVERSATIONS:
            frame.origin.x = 152;
            break;
        case BARBUTTONTYPE_FOLLOWERS:
            frame.origin.x = 215;
            break;
            
        default:
            break;
    }
    frame.origin.y = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 55 : 35;
    triangleImgView.frame = frame;
    
    [_topToolBar addSubview:triangleImgView];
}

- (void)animateTriangleArrowToBtnWithType:(BarButtonType)barBtnType
{
    UIImageView *triangleImgView = (UIImageView *)[_topToolBar viewWithTag:kTriangleViewTag];
    CGRect frame = triangleImgView.frame;
    
    switch (barBtnType) {
        case BARBUTTONTYPE_NOTIFICATIONS:
            frame.origin.x = 92;
            break;
        case BARBUTTONTYPE_CONVERSATIONS:
            frame.origin.x = 152;
            break;
        case BARBUTTONTYPE_FOLLOWERS:
            frame.origin.x = 215;
            break;
            
        default:
            break;
    }
    [UIView animateWithDuration:0.25f animations:^{
        triangleImgView.frame = frame;
    } completion:^(__unused BOOL finished) {
    }];
}

- (void)removeTriangleArrow
{
    UIView *triangleView = [_topToolBar viewWithTag:kTriangleViewTag];
    if (triangleView) {
        [triangleView removeFromSuperview];
    }
}

- (void)clearContentView
{
    for (id view in self.contentView.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void)pushViewController:(id)controller
{
    [self pushViewController:controller animated:YES];
}

#pragma mark - SDNotificationViewController delegate

- (void)notificationViewController:(SDNotificationViewController *)notificationViewController
            didSelectActivityStory:(ActivityStory *)activityStory
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"Notification_Selected"
                                                           value:nil] build]];
    
    SDActivityStoryViewController *activityStoryViewController = [[SDActivityStoryViewController alloc] init];
    activityStoryViewController.activityStory = activityStory;
    
    [self pushViewCOntrollerFromNotificationsViewController:activityStoryViewController];
}

- (void)notificationViewController:(SDNotificationViewController *)notificationViewController
                     didSelectUser:(User *)user
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"Notification_Selected"
                                                           value:nil] build]];
    
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = user;
    
    [self pushViewCOntrollerFromNotificationsViewController:userProfileViewController];
}

- (void)notificationViewControllerDidCheckForNewNotifications:(SDNotificationViewController *)notificationViewController
{
    [self checkServer];
}

- (void)pushViewCOntrollerFromNotificationsViewController:(UIViewController *)viewController
{
    [self hideNotificationsAndRemoveContentView:YES];
    
    //remember in which controller we will need to open following view
    [self rememberCurrentControllerForButtonType:BARBUTTONTYPE_NOTIFICATIONS];
    
    [self performSelector:@selector(pushViewController:)
               withObject:viewController
               afterDelay:0.2f];
}

#pragma mark - SDFollowingViewController delegate methods

- (void)followingViewController:(SDFollowingViewController *)followingViewController didSelectUser:(User *)user
{
    [self hideFollowersAndRemoveContentView:YES];
    
    //remember in which controller we will need to open following view
    [self rememberCurrentControllerForButtonType:BARBUTTONTYPE_FOLLOWERS];
    
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = user;
    
    [self performSelector:@selector(pushViewController:) withObject:userProfileViewController afterDelay:0.2f];
}

#pragma mark - SDMessageViewController delegate methods

- (void)messageViewController:(SDMessageViewController *)messageViewController
        didSelectConversation:(Conversation *)conversation
{
    if ([[[self viewControllers] lastObject] isKindOfClass:[SDConversationViewController class]]) {
        SDConversationViewController *conversationController = [[self viewControllers] lastObject];
        if ([conversationController.conversation.identifier isEqual:conversation.identifier]) {
            [self hideConversationsAndRemoveContentView:YES];
            return;
        }
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"Conversation_Selected"
                                                           value:nil] build]];
    
    //remember in which controller we will need to open following view
    [self rememberCurrentControllerForButtonType:BARBUTTONTYPE_CONVERSATIONS];
    
    [self hideConversationsAndRemoveContentView:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MessagesStoryboard"
                                                         bundle:nil];
    SDConversationViewController *conversationViewController = (SDConversationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
    conversationViewController.conversation = conversation;
    
    [self performSelector:@selector(pushViewController:) withObject:conversationViewController afterDelay:0.2f];
}

- (void)didStartNewConversationInMessageViewController:(SDMessageViewController *)messageViewController
{
    //remember in which controller we will need to open following view
    [self rememberCurrentControllerForButtonType:BARBUTTONTYPE_CONVERSATIONS];
    
    [self hideConversationsAndRemoveContentView:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MessagesStoryboard"
                                                         bundle:nil];
    SDNewConversationViewController *newMessageNavigationController = (SDNewConversationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NewConversationViewController"];
    [self pushViewController:newMessageNavigationController animated:YES];
}

#pragma mark - Top toolbar delegate

- (void)leftButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView
{
    if ([self.viewControllers count] > 1 && _backButtonVisibleIfNeeded)
        [self popViewController];
    else
        [self revealMenu:nil];
}

- (void)rightButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView
{
    [self filterButtonSelected];
}

- (void)notificationButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView
{
    [self notificationsSelected];
}

- (void)conversationButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView
{
    [self conversationsSelected];
}

- (void)followerButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView
{
    [self followersSelected];
}

- (void)anyButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView
{
    [self hideKeyboardsOfUIResponders];
}

#pragma mark - Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - navigation

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (self.lastControllerForToolbarItems) {
        if ([self.lastControllerForToolbarItems isEqual:[self.viewControllers objectAtIndex:[self.viewControllers count]-2]]) {
            //found right controller, show proper view (following, conversations or notifications)
            if (self.lastSelectedType == BARBUTTONTYPE_CONVERSATIONS) {
                [self performSelector:@selector(showConversations) withObject:nil afterDelay:0.2f];
                //                [self showConversations];
            }
            else if (self.lastSelectedType == BARBUTTONTYPE_FOLLOWERS) {
                [self performSelector:@selector(showFollowers) withObject:nil afterDelay:0.2f];
                //                [self showFollowers];
            }
            else if (self.lastSelectedType == BARBUTTONTYPE_NOTIFICATIONS) {
                
            }
            else {
                //do nothing if the button type == BARBUTTONTYPE_NONE
            }
            [self forgetLastController];
        }
    }
    
    [super popViewControllerAnimated:animated];
    return [self.viewControllers lastObject];
}


#pragma mark - Navigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.navigationInProgress = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.navigationInProgress = NO;
    NSLog(@"navigationController did show %@",[viewController class]);
}

@end
