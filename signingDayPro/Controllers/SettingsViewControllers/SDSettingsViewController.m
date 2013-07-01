//
//  SDSettingsViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/28/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDSettingsViewController.h"
#import "SDLoginService.h"

@interface SDSettingsViewController ()

- (IBAction)logout:(id)sender;

@end

@implementation SDSettingsViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)logout:(id)sender
{
    [SDLoginService logout];
    [self showLoginScreen];
}

@end
