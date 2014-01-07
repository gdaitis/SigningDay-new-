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

@interface SDPlayerSearchViewController ()

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
    
    self.screenName = @"Claim account screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
