//
//  SDBaseViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseViewController.h"
#import "MBProgressHUD.h"
#import "Master.h"
#import "User.h"
#import "SDLoginService.h"
#import "SDNavigationController.h"
#import "IIViewDeckController.h"

@interface SDBaseViewController ()

//@property (nonatomic, strong) SDLoginViewController *loginViewController;

@end

@implementation SDBaseViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(checkServer) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
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

- (void)showProgressHudInView:(UIView *)view withText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (text) {
        hud.labelText = text;
    }
}

- (void)hideProgressHudInView:(UIView *)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

#pragma mark - Loader methods

- (void)beginRefreshing
{
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
}

- (void)endRefreshing
{
    [self.refreshControl endRefreshing];
}

- (void)checkServer
{
    // override this in a subclass
}

#pragma mark - SDLoginViewController login & delegate methods

- (void)loginViewControllerDidFinishLoggingIn:(SDLoginViewController *)loginViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpdatedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)userDidLogout
{
    //optionally may call some functions to clear views and some data
    [self showLoginScreen];
}

- (void)showLoginScreen
{
//    if (!self.loginViewController) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
//        SDLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        self.loginViewController = loginVC;
//        [_loginViewController setModalPresentationStyle:UIModalPresentationFullScreen];
//        _loginViewController.delegate = self;
//        
//        [self presentViewController:_loginViewController animated:YES completion:^{
//            
//        }];
//    } else if (!(_loginViewController.isViewLoaded && _loginViewController.view.window)) {
//        [self presentViewController:_loginViewController animated:YES completion:^{
//            
//        }];
//    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
    SDLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [loginVC setModalPresentationStyle:UIModalPresentationFullScreen];
    loginVC.delegate = self;
    
    [self presentViewController:loginVC
                       animated:YES
                     completion:nil];

}


@end
