//
//  SDCoachSearchViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/9/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDCoachSearchViewController.h"
#import "SDStandartNavigationController.h"
#import "SDLandingPagesService.h"
#import "User.h"
#import "Team.h"
#import "Coach.h"

@interface SDCoachSearchViewController ()

@end

@implementation SDCoachSearchViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [(SDStandartNavigationController *)self.navigationController setNavigationTitle:@"Claim Account"];
    
    self.screenName = @"ClaimAccount_CoachSearchScreen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkServerForUsersWithNameSubstring:(NSString *)nameSubstring
{
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    [SDLandingPagesService searchAllCoachesWithNameSubstring:nameSubstring successBlock:^{
        [self dataLoadedForSearchString:nameSubstring];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        
        [self hideProgressHudInView:self.view];
    }];
}

- (NSString *)addressTitleForUser:(User *)user
{
    NSString *result = user.theCoach.institution;
    return result;
}

@end
