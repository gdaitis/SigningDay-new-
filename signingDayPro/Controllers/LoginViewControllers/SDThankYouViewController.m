//
//  SDThankYouViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/10/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDThankYouViewController.h"
#import "SDStandartNavigationController.h"

@interface SDThankYouViewController ()

@property (nonatomic, weak) UILabel *infoLabel;
@property (nonatomic, weak) UIButton *homeButton;

@end

@implementation SDThankYouViewController

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
    
    [self setupUIElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [(SDStandartNavigationController *)self.navigationController setNavigationTitle:@"Thank you"];
    [self setupTextAndPositions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUIElements
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor colorWithRed:83.0f/255.0f green:83.0f/255.0f blue:83.0f/255.0f alpha:1.0f];
    label.font = [UIFont systemFontOfSize:20];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    self.infoLabel = label;
    [self.view addSubview:self.infoLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 150, 36);
    UIImage *buttonImage = [[UIImage imageNamed:@"CantFindYourselfRegisterButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:48.0f/255.0f green:42.0f/255.0f blue:6.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(homeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"BebasNeue" size:22]];
    
    self.homeButton = button;
    [self.view addSubview:self.homeButton];
}

- (void)setupTextAndPositions
{
    self.infoLabel.text = self.infoText;
    [self.homeButton setTitle:self.buttonText forState:UIControlStateNormal];
    int offsetFromSides = 20;
    
    self.homeButton.center = self.view.center;
    self.infoLabel.center = self.view.center;
    CGSize size = [self.infoLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width - (offsetFromSides * 2), MAXFLOAT)];
    CGRect frame = self.infoLabel.frame;
    frame.size = size;
    frame.origin.x = offsetFromSides;
    frame.origin.y = self.homeButton.frame.origin.y - offsetFromSides - size.height;
    self.infoLabel.frame = frame;
}

- (void)homeButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
