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

@interface SDNavigationController ()

//properties for presenting toolbar menus on navigating back
@property (nonatomic, strong) UIViewController *lastControllerForToolbarItems;
@property (nonatomic, assign) BarButtonType lastSelectedType;
@property (nonatomic, assign) BOOL showFilterButton;
@property (nonatomic, assign) BOOL filterViewVisible;
@property (nonatomic, strong) UIView *ios7bar;

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
    
    _selectedMenuType = BARBUTTONTYPE_NONE;
    _backButtonVisibleIfNeeded = YES;
    
    //creates and adds buttons to the top toolbar
    [self setupToolbar];
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

#pragma mark - Toolbar

- (void)setupToolbar
{
    //creating and adding toolbar
    float y = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 20 : 0;
    if (!self.topToolBar) {
        SDCustomNavigationToolbarView *toolbarView = (id)[SDCustomNavigationToolbarView loadInstanceFromNib];
        
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
    [self popViewControllerAnimated:YES];
    [self setToolbarButtons];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self.view bringSubviewToFront:_topToolBar];
    [self setToolbarButtons];
}

- (void)setToolbarButtons
{
    //set left button actions
    [self.topToolBar.leftButton removeTarget:nil
                                      action:NULL
                            forControlEvents:UIControlEventAllEvents];
    
    UIImage *btnImg = nil;
    if ([self.viewControllers count] > 1 && _backButtonVisibleIfNeeded) {
        btnImg = [UIImage imageNamed:@"MenuButtonBack.png"];
        [self.topToolBar.leftButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        btnImg = [UIImage imageNamed:@"MenuButton.png"];
        [self.topToolBar.leftButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.topToolBar.leftButton setImage:btnImg forState:UIControlStateNormal];
    
    //set midle button actions
    [self.topToolBar.notificationButton addTarget:self action:@selector(notificationsSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.topToolBar.notificationButton.selected = (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) ? YES : NO;
    
    [self.topToolBar.messagesButton addTarget:self action:@selector(conversationsSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.topToolBar.messagesButton.selected = (_selectedMenuType == BARBUTTONTYPE_CONVERSATIONS)? YES : NO;
    
    [self.topToolBar.followersButton addTarget:self action:@selector(followersSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.topToolBar.followersButton.selected = (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) ? YES : NO;
    
    
    //check is filter button needed
    if (self.showFilterButton) {
        UIImage *btnImg = [UIImage imageNamed:@"LandingPageFilterButton.png"];
        
        [self.topToolBar.rightButton setImage:btnImg forState:UIControlStateNormal];
        [self.topToolBar.rightButton addTarget:self action:@selector(filterButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.topToolBar.rightButton.selected = (self.filterViewVisible) ? YES : NO;
        self.topToolBar.rightButton.hidden = NO;
    }
    else {
        self.topToolBar.rightButton.hidden = YES;
    }
}

#pragma mark - Toolbar button actions

- (void)notificationsSelected:(UIButton *)btn
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
        btn.selected = YES;
        [self showNotifications];
    }
    [self setToolbarButtons];
}

- (void)conversationsSelected:(UIButton *)btn
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
        btn.selected = YES;
        [self showConversations];
    }
    [self setToolbarButtons];
}

- (void)followersSelected:(UIButton *)btn
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


- (void)filterButtonSelected:(id)sender
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
    _selectedMenuType = BARBUTTONTYPE_NOTIFICATIONS;
    if (!_notificationVC) {
        SDNotificationViewController *notificationVC = [[SDNotificationViewController alloc] init];
        //        notificationVC.delegate = self;
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
    
    [self.view bringSubviewToFront:self.ios7bar];
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
    
    [self.view bringSubviewToFront:self.ios7bar];
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

- (void)notificationViewController:(SDNotificationViewController *)notificationViewController didSelectUser:(User *)user //should be did select notification
{
    [self hideFollowersAndRemoveContentView:YES];
    
    //remember in which controller we will need to open following view
    [self rememberCurrentControllerForButtonType:BARBUTTONTYPE_NOTIFICATIONS];
    
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = user;
    
    [self performSelector:@selector(pushViewController:) withObject:userProfileViewController afterDelay:0.2f];
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


@end
