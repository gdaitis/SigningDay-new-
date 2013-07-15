//
//  SDModalNavigationController.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDModalNavigationController.h"

@interface SDModalNavigationController ()

@end

@implementation SDModalNavigationController

- (void)setToolbarButtons
{
    //setting menu/Back button and other middle buttons
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = nil;
    if ([self.viewControllers count] > 1 && self.backButtonVisibleIfNeeded) {
        btnImg = [UIImage imageNamed:@"MenuButtonBack.png"];
        [btn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        btnImg = [UIImage imageNamed:@"MenuButton.png"];
        [btn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
    btn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
    self.menuButton = btn;
    [self.menuButton setImage:btnImg forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
    fixedSpace.width = 11;
    UIBarButtonItem *fixedSmallSpace = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil
                                        action:nil];
    fixedSmallSpace.width = 10;
    
    UIBarButtonItem *menuBarBtnItm = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    
    NSArray *btnArray = [NSArray arrayWithObjects:menuBarBtnItm, fixedSpace, [self barButtonForType:BARBUTTONTYPE_NOTIFICATIONS],fixedSmallSpace,[self barButtonForType:BARBUTTONTYPE_CONVERSATIONS],fixedSmallSpace, [self barButtonForType:BARBUTTONTYPE_FOLLOWERS], nil];
    [self.topToolBar setItems:btnArray animated:NO];
}

@end
