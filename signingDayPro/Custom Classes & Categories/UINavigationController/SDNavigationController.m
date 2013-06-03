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
#import "SDFollowingViewController.h"
#import "SDFollowingService.h"

typedef enum {
    BARBUTTONTYPE_NOTIFICATIONS = 0,
    BARBUTTONTYPE_CONVERSATIONS,
    BARBUTTONTYPE_FOLLOWERS,
    BARBUTTONTYPE_NONE
} BarButtonType;

#define kTriangleViewTag 999

@interface SDNavigationController ()

- (void)setToolbarButtons;
- (void)popViewController;
- (void)setupToolbar;
- (void)showConversations;
- (void)revealMenu:(id)sender;

@property (nonatomic, weak) UIToolbar *topToolBar;
@property (nonatomic, assign) BarButtonType *barButtonType;

@property (nonatomic, strong) SDMessageViewController *messageVC;
@property (nonatomic, strong) SDFollowingViewController *followingVC;

@property (nonatomic, assign) BarButtonType selectedMenuType;

@end

@implementation SDNavigationController

@synthesize menuButton = _menuButton;
@synthesize topToolBar = _topToolBar;
@synthesize barButtonType = _barButtonType;
@synthesize messageVC = _messageVC;
@synthesize followingVC = _followingVC;
@synthesize selectedMenuType = _selectedMenuType;

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
    self.navigationBarHidden = YES;
    _selectedMenuType = BARBUTTONTYPE_NONE;
    
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
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.topToolBar = tb;
    [_topToolBar setBackgroundImage:[UIImage imageNamed:@"ToolbarBg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:_topToolBar];
    
    [self setToolbarButtons];
}

#pragma mark - Navigation

- (void)popViewController
{
    [self popViewControllerAnimated:YES];
    [self setToolbarButtons];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self setToolbarButtons];
}

- (void)setToolbarButtons
{
    //setting menu/Back button and other middle buttons
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = nil;
    if ([self.viewControllers count] > 1) {
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
            break;
        case BARBUTTONTYPE_CONVERSATIONS:
            btnImg = [UIImage imageNamed:@"MailIcon.png"];
            btnHighlightedImg = [UIImage imageNamed:@"MailIconActive.png"];
            [btn addTarget:self action:@selector(conversationsSelected:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 2;
            break;
        case BARBUTTONTYPE_FOLLOWERS:
            btnImg = [UIImage imageNamed:@"FollowersIcon.png"];
            btnHighlightedImg = [UIImage imageNamed:@"FollowersIconActive.png"];
            [btn addTarget:self action:@selector(followersSelected:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 3;
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
        btn.selected = NO;
        [self hideConversations];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) {
        [self hideFollowers];
        [self showConversations];
        btn.selected = YES;
    }
    else if (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) {
//        [self hideNotifications];
    }
    else {
        //_selectedMenuType == BARBUTTONTYPE_NONE
        btn.selected = YES;
        [self showConversations];
    }
    [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromBottom forView:self.navigationController.view cache:NO];

    
}

- (void)followersSelected:(UIButton *)btn
{
    if (_selectedMenuType == BARBUTTONTYPE_CONVERSATIONS) {
        [self hideConversations];
        [self showFollowers];
        btn.selected= YES;
    }
    else if (_selectedMenuType == BARBUTTONTYPE_FOLLOWERS) {
        btn.selected = NO;
        [self hideFollowers];
    }
    else if (_selectedMenuType == BARBUTTONTYPE_NOTIFICATIONS) {
        //        [self hideNotifications];
    }
    else {
        //_selectedMenuType == BARBUTTONTYPE_NONE
        btn.selected = YES;
        [self showFollowers];
    }
    [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromBottom forView:self.navigationController.view cache:NO];
}

#pragma mark - Displaying top menu

- (void)showConversations
{
    _selectedMenuType = BARBUTTONTYPE_CONVERSATIONS;
    if (!_messageVC) {
        SDMessageViewController *sdmessageVC = [[SDMessageViewController alloc] init];
        sdmessageVC.view.frame = CGRectMake(0, -self.view.bounds.size.height+_topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
        
        self.messageVC = sdmessageVC;
    }
    
    [self.view addSubview:_messageVC.view];
    [self.view bringSubviewToFront:_topToolBar];

    [self addTriangleArrowForBtnType:BARBUTTONTYPE_CONVERSATIONS];
    
    [UIView animateWithDuration:0.25f animations:^{
        _messageVC.view.frame = CGRectMake(0, _topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
    } completion:^(__unused BOOL finished) {
    }];
    
    [_messageVC loadInfo];
}

- (void)hideConversations
{
    _selectedMenuType = BARBUTTONTYPE_NONE;
    if (_messageVC) {
        [UIView animateWithDuration:0.25f animations:^{
            _messageVC.view.frame = CGRectMake(0, -self.view.bounds.size.height+_topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
        } completion:^(__unused BOOL finished) {
            [self removeTriangleArrow];
            [_messageVC.view removeFromSuperview];
        }];
    }
}

- (void)showFollowers
{
    _selectedMenuType = BARBUTTONTYPE_FOLLOWERS;
    if (!_followingVC) {
        SDFollowingViewController *sdfollowingVC = [[SDFollowingViewController alloc] init];
        sdfollowingVC.view.frame = CGRectMake(0, -self.view.bounds.size.height+_topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
        
        self.followingVC = sdfollowingVC;
    }
    
    [self.view addSubview:_followingVC.view];
    [self.view bringSubviewToFront:_topToolBar];
    
    [self addTriangleArrowForBtnType:BARBUTTONTYPE_FOLLOWERS];
    
    [UIView animateWithDuration:0.25f animations:^{
        _followingVC.view.frame = CGRectMake(0, _topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
    } completion:^(__unused BOOL finished) {
        [_followingVC loadInfo];
    }];
}

- (void)hideFollowers
{
    _selectedMenuType = BARBUTTONTYPE_NONE;
    if (_followingVC) {
        [UIView animateWithDuration:0.25f animations:^{
            _followingVC.view.frame = CGRectMake(0, -self.view.bounds.size.height+_topToolBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_topToolBar.frame.size.height);
        } completion:^(__unused BOOL finished) {
            [self removeTriangleArrow];
            [_followingVC.view removeFromSuperview];
            [SDFollowingService deleteUnnecessaryUsers];
        }];
    }
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

- (void)removeTriangleArrow
{
    UIView *triangleView = [_topToolBar viewWithTag:kTriangleViewTag];
    if (triangleView) {
        [triangleView removeFromSuperview];
    }
}

@end
