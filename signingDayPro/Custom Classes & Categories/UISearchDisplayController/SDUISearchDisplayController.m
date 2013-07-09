//
//  SD.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/9/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUISearchDisplayController.h"

@implementation SDUISearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive: visible animated: animated];
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}

@end
