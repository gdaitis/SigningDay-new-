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

@interface SDUserProfileViewController ()

@property (nonatomic,assign) BOOL firstLoad;

@end

@implementation SDUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstLoad = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkServer];
}

- (void)checkServer
{
    if (_firstLoad) {
        [self showProgressHudInView:self.viewDeckController.view withText:@"Updating"];
        _firstLoad = NO;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
        
        [SDProfileService getProfileInfoForUserIdentifier:[self getMasterIdentifier] completionBlock:^{
            [self hideProgressHudInView:self.viewDeckController.view];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpdatedNotification object:nil];
        } failureBlock:^{
            [self hideProgressHudInView:self.viewDeckController.view];
        }];
        
    }
}

@end
