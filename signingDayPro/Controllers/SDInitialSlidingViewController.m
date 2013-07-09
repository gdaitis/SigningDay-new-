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
#import "SDLoginViewController.h"

@interface SDInitialSlidingViewController ()

@end

@implementation SDInitialSlidingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIStoryboard *userProfileStoryboard = [UIStoryboard storyboardWithName:@"ActivityFeedStoryboard" bundle:nil];
    self = [super initWithCenterViewController:[userProfileStoryboard instantiateViewControllerWithIdentifier:@"SDActivityFeedNavigationController"]
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


@end
