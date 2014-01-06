//
//  SDLoginViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDLoginViewController.h"
#import "SDLoginService.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"
#import "SDTermsViewController.h"
#import "SDWebViewController.h"
#import "SDJoinViewController.h"
#import "SDNavigationController.h"

@interface SDLoginViewController () <UITextFieldDelegate, SDJoinViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)helpCenterButtonPressed:(UIButton *)sender;
- (IBAction)forgotPasswordButtonPressed:(UIButton *)sender;
- (IBAction)registerButtonPressed:(UIButton *)sender;

@end

@implementation SDLoginViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.backgroundImageView addGestureRecognizer:recognizer];
    
    UIImage *bgImage;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height == 480) {
        bgImage = [UIImage imageNamed:@"login_bg.png"];
    }
    if (screenSize.height == 568) {
        bgImage = [UIImage imageNamed:@"login_bg-568h@2x.png"];
    }
    self.backgroundImageView.image = bgImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Login screen";
}

- (void)closeKeyboard
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)userDidLogout
{
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
}

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(id)sender 
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    [SDLoginService loginWithUsername:username password:password facebookToken:nil successBlock:^{
        [self.delegate loginViewControllerDidFinishLoggingIn:self];
    } failBlock:^{
        [SDLoginService logoutWithSuccessBlock:nil failureBlock:nil];
    }];
}

- (IBAction)connectWithFacebookPressed:(id)sender
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
        appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
    }
    
    [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        NSLog(@"FB access token: %@", appDelegate.fbSession.accessTokenData.accessToken);
        if (status == FBSessionStateOpen) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
            hud.labelText = @"Logging in";
            [SDLoginService loginWithUsername:nil password:nil facebookToken:appDelegate.fbSession.accessTokenData.accessToken successBlock:^{
                [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                [self.delegate loginViewControllerDidFinishLoggingIn:self];
            }failBlock:^{
                 
             }];
        }
    }];
}

- (IBAction)connectWithTwitterPressed:(id)sender
{
    
}

- (IBAction)forgotPasswordButtonPressed:(UIButton *)sender
{
    SDWebViewController *viewController = [[SDWebViewController alloc] initWithNibName:@"SDWebViewController" bundle:[NSBundle mainBundle]];
    viewController.urlString = @"user/emailforgottenpassword.aspx";
    viewController.gaScreenName = @"Forgot password screen";
    viewController.navigationTitle = @"Forgot Password";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:^{
        
    }];
}

- (IBAction)helpCenterButtonPressed:(UIButton *)sender
{
    SDWebViewController *viewController = [[SDWebViewController alloc] initWithNibName:@"SDWebViewController" bundle:[NSBundle mainBundle]];
//    viewController.urlString = @"p/faq.aspx";
    viewController.fileName = @"FAQhtml";
    viewController.gaScreenName = @"Help center screen";
    viewController.navigationTitle = @"Help center";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:^{
        
    }];
}

- (IBAction)registerButtonPressed:(UIButton *)sender
{
    SDJoinViewController *joinViewController = [[SDJoinViewController alloc] initWithNibName:@"SDJoinViewController" bundle:nil];
    joinViewController.delegate = self;
    
    [self.navigationController pushViewController:joinViewController animated:YES];
//    SDNavigationController *navigationController = [[SDNavigationController alloc] initWithRootViewController:viewController];
//    [self presentViewController:navigationController animated:YES completion:^{
//        
//    }];
}

- (void)bakcPressedInJoinViewController:(SDJoinViewController *)joinViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidUnload 
{
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField)
        [self.passwordTextField becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

@end
