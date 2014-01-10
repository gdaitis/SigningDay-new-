//
//  SDTeamSearchViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/9/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDHighSchoolSearchViewController.h"
#import "SDNavigationController.h"
#import "SDCustomNavigationToolbarView.h"
#import "SDStandartNavigationController.h"
#import "SDLandingPagesService.h"
#import "HighSchool.h"
#import "User.h"

@interface SDHighSchoolSearchViewController ()

@end

@implementation SDHighSchoolSearchViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [(SDStandartNavigationController *)self.navigationController setNavigationTitle:@"Claim Account"];
    self.screenName = @"ClaimAccount_HighSchoolSearchScreen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkServerForUsersWithNameSubstring:(NSString *)nameSubstring
{
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    [SDLandingPagesService searchAllHighSchoolsWithNameSubstring:nameSubstring successBlock:^{
        [self dataLoadedForSearchString:nameSubstring];
        [self hideProgressHudInView:self.view];
        
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
}

- (NSString *)addressTitleForUser:(User *)user
{
    NSString *result = user.theHighSchool.address;
    return result;
}

@end
