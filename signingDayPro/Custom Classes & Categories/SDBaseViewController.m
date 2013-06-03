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

@interface SDBaseViewController ()

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

- (NSNumber *)getMasterIdentifier
{
    Master *master = [self getMaster];
    return master.identifier;
}

- (Master *)getMaster
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    return master;
}

@end
