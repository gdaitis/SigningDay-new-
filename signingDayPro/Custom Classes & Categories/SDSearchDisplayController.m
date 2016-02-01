//
//  SDSearchDisplayController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/8/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDSearchDisplayController.h"

@implementation SDSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive: visible animated: animated];
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}

@end
