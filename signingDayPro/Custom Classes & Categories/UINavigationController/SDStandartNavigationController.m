//
//  SDStandartNavigationController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/3/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDStandartNavigationController.h"

@interface SDStandartNavigationController () <UINavigationControllerDelegate>

@end

@implementation SDStandartNavigationController

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
    UIImage *backgroundImage = ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) ? [UIImage imageNamed:@"toolbarBgIphone5.png"] : [UIImage imageNamed:@"NavigationBarBgIOS7.png"];
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self setupButtons];
}

- (void)setupButtons
{
    [[[self.viewControllers lastObject] navigationItem ] setLeftBarButtonItem:nil];
    UIImage *leftButtonImage = ([self.viewControllers count] > 1) ? [UIImage imageNamed:@"MenuButtonBack.png"] : nil;
    if (leftButtonImage) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
        [leftButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setBackgroundImage:leftButtonImage forState:UIControlStateNormal];
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [[[self.viewControllers lastObject] navigationItem ] setLeftBarButtonItem:leftBarButtonItem];
    }
}

- (void)setupNavigationTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = NSTextAlignmentCenter;
    
    label.textColor = [UIColor whiteColor]; // change this color
    label.text = title;
    [label sizeToFit];
    [[[self.viewControllers lastObject] navigationItem] setTitleView:label];
    
}

- (void)setNavigationTitle:(NSString *)title
{
    [self setupNavigationTitle:title];
}

- (void)backButtonPressed:(id)sender
{
    [self popViewControllerAnimated:YES];
}

@end
