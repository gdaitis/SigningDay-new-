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

@interface SDNavigationController ()

//properties for presenting toolbar menus on navigating back
@property (nonatomic, strong) UIViewController *lastControllerForToolbarItems;
@property (nonatomic, assign) BarButtonType lastSelectedType;


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
//    self.navigationBarHidden = YES;
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
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTopToolbarHeight)];
    self.topToolBar = tb;
    [_topToolBar setBackgroundImage:[UIImage imageNamed:@"ToolbarBg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:_topToolBar];
    
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
    //setting menu/Back button and other middle buttons
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = nil;
    if ([self.viewControllers count] > 1 && _backButtonVisibleIfNeeded) {
        btnImg = [UIImage imageNamed:@"MenuButtonBack.png"];
        [btn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        btnImg = [UIImage imageNamed:@"MenuButton.png"];
        [btn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
    btn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
    self.menuButton = btn;
    [_menuButton setImage:btnImg forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
    fixedSpace.width = 11;
    UIBarButtonItem *fixedSmallSpace = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil
                                        action:nil];
    fixedSmallSpace.width = 10;
    
    UIBarButtonItem *menuBarBtnItm = [[UIBarButtonItem alloc] initWithCustomView:_menuButton];
    
    NSArray *btnArray = [NSArray arrayWithObjects:menuBarBtnItm, fixedSpace, [self barButtonForType:BARBUTTONTYPE_NOTIFICATIONS],fixedSmallSpace,[self barButtonForType:BARBUTTONTYPE_CONVERSATIONS],fixedSmallSpace, [self barButtonForType:BARBUTTONTYPE_FOLLOWERS], nil];
    [_topToolBar setItems:btnArray animated:NO];
}

- (UIBarButtonItem *)barButtonForType:(BarButtonType)type
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = nil;
    UIImage *btnHighlightedImg = nil;
    
    switch (type) {
        case BARBUTTONTYPE_NOTIFICATIONS:
            btnImg = [UIImage imageNamed:@"NotificationIcon.png"];
            btnHighlightedImg = [UIImage imageNamed:@"NotificationIconActive.png"];
            [btn addTarget:self action:@selector(notificationsSelected:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 1;
            if (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) {
                btn.selected = YES;
            }
            break;
        case BARBUTTONTYPE_CONVERSATIONS:
            btnImg = [UIImage imageNamed:@"MailIcon.png"];
            btnHighlightedImg = [UIImage imageNamed:@"MailIconActive.png"];
            [btn addTarget:self action:@selector(conversationsSelected:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 2;
            if (_selectedMenuType == BARBUTTONTYPE_CONVERSATIONS) {
                btn.selected = YES;
            }
            break;
        case BARBUTTONTYPE_FOLLOWERS:
            btnImg = [UIImage imageNamed:@"FollowersIcon.png"];
            btnHighlightedImg = [UIImage imageNamed:@"FollowersIconActive.png"];
            [btn addTarget:self action:@selector(followersSelected:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 3;
            if (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) {
                btn.selected = YES;
            }
            break;
            
        default:
            break;
    }
    btn.frame = CGRectMake(0, 0, 50, 40);
    [btn setContentMode:UIViewContentModeCenter];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn setImage:btnHighlightedImg forState:UIControlStateSelected];
    
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return result;
}

#pragma mark - Toolbar button actions

- (void)notificationsSelected:(UIButton *)btn
{
    btn.selected = !btn.selected;
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
//        [self hideNotifications];
    }
    else {
        btn.selected = YES;
        [self showConversations];
    }
    [self setToolbarButtons];
//    [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromBottom forView:self.navigationController.view cache:NO];
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
        //        [self hideNotifications];
    }
    else {
        [self showFollowers];
    }
    [self setToolbarButtons];
}

#pragma mark - Displaying top menu

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
            frame.origin.x = 87;
            break;
        case BARBUTTONTYPE_CONVERSATIONS:
            frame.origin.x = 152;
            break;
        case BARBUTTONTYPE_FOLLOWERS:
            frame.origin.x = 224;
            break;
            
        default:
            break;
    }
    frame.origin.y = 35;
    triangleImgView.frame = frame;
    
    [_topToolBar addSubview:triangleImgView];
}

- (void)animateTriangleArrowToBtnWithType:(BarButtonType)barBtnType
{
    UIImageView *triangleImgView = (UIImageView *)[_topToolBar viewWithTag:kTriangleViewTag];
    CGRect frame = triangleImgView.frame;
    
    switch (barBtnType) {
        case BARBUTTONTYPE_NOTIFICATIONS:
            frame.origin.x = 87;
            break;
        case BARBUTTONTYPE_CONVERSATIONS:
            frame.origin.x = 152;
            break;
        case BARBUTTONTYPE_FOLLOWERS:
            frame.origin.x = 224;
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
