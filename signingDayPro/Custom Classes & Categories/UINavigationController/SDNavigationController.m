//
//  SDNavigationController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/27/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNavigationController.h"
#import "ECSlidingViewController.h"

typedef enum {
    BARBUTTONTYPE_NOTIFICATIONS = 0,
    BARBUTTONTYPE_CONVERSATIONS,
    BARBUTTONTYPE_FOLLOWERS,
    BARBUTTONTYPE_FLEXIBLESPACE
} BarButtonType;

@interface SDNavigationController ()

- (void)setToolbarButtons;
- (void)popViewController;
- (void)setupToolbar;
- (void)revealMenu:(id)sender;

@property (nonatomic, weak) UIToolbar *topToolBar;
@property (nonatomic, assign) BarButtonType *barButtonType;

@end

@implementation SDNavigationController

@synthesize menuButton = _menuButton;
@synthesize topToolBar = _topToolBar;
@synthesize barButtonType = _barButtonType;

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
    [self.slidingViewController anchorTopViewTo:ECRight];
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
    fixedSpace.width = 35;
    UIBarButtonItem *fixedSmallSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
    fixedSmallSpace.width = 30;
    
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
            break;
        case BARBUTTONTYPE_CONVERSATIONS:
            btnImg = [UIImage imageNamed:@"MailIcon.png"];
            btnHighlightedImg = [UIImage imageNamed:@"MailIconActive.png"];
            [btn addTarget:self action:@selector(conversationsSelected:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case BARBUTTONTYPE_FOLLOWERS:
            btnImg = [UIImage imageNamed:@"FollowersIcon.png"];
            btnHighlightedImg = [UIImage imageNamed:@"FollowersIconActive.png"];
            [btn addTarget:self action:@selector(followersSelected:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        default:
            break;
    }
    btn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
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
    btn.selected = !btn.selected;
}

- (void)followersSelected:(UIButton *)btn
{
    btn.selected = !btn.selected;
}

@end
