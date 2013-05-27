//
//  SDInitialSlidingViewViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDInitialSlidingViewViewController.h"

@interface SDInitialSlidingViewViewController ()

@end

@implementation SDInitialSlidingViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"SDViewController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
