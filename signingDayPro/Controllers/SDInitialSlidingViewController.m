//
//  SDInitialSlidingViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDInitialSlidingViewController.h"
#import "SDLoginService.h"
#import "SDAPIClient.h"
#import "SDLoginViewController.h"

@interface SDInitialSlidingViewController () <SDLoginViewControllerDelegate>

@property (nonatomic, strong) SDLoginViewController *loginViewController;

- (void)loginViewControllerDidFinishLoggingIn:(SDLoginViewController *)loginViewController;

@end

@implementation SDInitialSlidingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIStoryboard *userProfileStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard" bundle:nil];
    self = [super initWithCenterViewController:[userProfileStoryboard instantiateViewControllerWithIdentifier:@"SDViewNavigationController"]
                            leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"Menu"]];
    if (self) {
        // Add any extra init code here
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"])
        [self showLoginScreen];
}

- (void)showLoginScreen
{
    if (!self.loginViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
        SDLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.loginViewController = loginVC;
        [_loginViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        _loginViewController.delegate = self;
        
        [self presentModalViewController:_loginViewController animated:YES];
    } else if (!(_loginViewController.isViewLoaded && _loginViewController.view.window)) {
        [self presentModalViewController:_loginViewController animated:YES];
    }
}

#pragma mark - SDLoginViewController delegate methods

- (void)loginViewControllerDidFinishLoggingIn:(SDLoginViewController *)loginViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpdatedNotification object:nil];
    [self dismissModalViewControllerAnimated:YES];
}

@end
