//
//  SDNavigationTopViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNavigationTopViewController.h"

@interface SDNavigationTopViewController ()

@end

@implementation SDNavigationTopViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[SDMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
        
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

@end
