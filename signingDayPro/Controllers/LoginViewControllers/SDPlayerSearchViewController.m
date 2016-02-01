//
//  SDClaimAccountViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/2/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDPlayerSearchViewController.h"
#import "SDNavigationController.h"
#import "SDCustomNavigationToolbarView.h"
#import "SDCantFindYourselfView.h"
#import "SDStandartNavigationController.h"
#import "SDLandingPagesService.h"
#import "HighSchool.h"
#import "SDRegisterViewController.h"
#import "Player.h"
#import "UIView+NibLoading.h"

@interface SDPlayerSearchViewController () <SDCantFindYourselfViewDelegate>

@end

@implementation SDPlayerSearchViewController

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
    
    self.screenName = @"ClaimAccount_PlayerSearchScreen";
    [self addCantFindYourselfView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCantFindYourselfView
{
    SDCantFindYourselfView *cantFindYourselfView = (id)[SDCantFindYourselfView loadInstanceFromNib];
    cantFindYourselfView.delegate = self;
    
    CGRect frame = cantFindYourselfView.frame;
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    cantFindYourselfView.frame = frame;
    
    frame = self.tableView.frame;
    frame.size.height = self.view.bounds.size.height - cantFindYourselfView.frame.size.height;
    self.tableView.frame = frame;
    
    [self.view addSubview:cantFindYourselfView];
}


- (void)checkServerForUsersWithNameSubstring:(NSString *)nameSubstring
{
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    [SDLandingPagesService searchAllPlayersWithNameSubstring:nameSubstring successBlock:^{
        [self dataLoadedForSearchString:nameSubstring];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        
        [self hideProgressHudInView:self.view];
    }];
}

- (NSString *)addressTitleForUser:(User *)user
{
    NSString *result = user.thePlayer.highSchool.theUser.name;
    return result;
}

- (void)registerButtonPressedInCantFindYourselfView:(SDCantFindYourselfView *)cantFindYourselfView
{
    SDRegisterViewController *rvc = [[SDRegisterViewController alloc] init];
    rvc.userType = self.userType;
    [self.navigationController pushViewController:rvc animated:YES];
}

@end
