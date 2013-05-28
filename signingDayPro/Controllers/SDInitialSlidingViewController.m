//
//  SDInitialSlidingViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDInitialSlidingViewController.h"

@interface SDInitialSlidingViewController ()

@end

@implementation SDInitialSlidingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIStoryboard *userProfileStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard" bundle:nil];
    self = [super initWithCenterViewController:[userProfileStoryboard instantiateViewControllerWithIdentifier:@"SDViewNavigationController"]
                            leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"Menu"]];
    if (self) {
        // Add any extra init code here
    }
    return self;
}

@end
