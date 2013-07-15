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
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = nil;
    btnImg = [UIImage imageNamed:@"MenuButtonClose@2x.png"];
    [btn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
    self.menuButton = btn;
    [self.menuButton setImage:btnImg forState:UIControlStateNormal];
    
    UIBarButtonItem *menuBarBtnItm = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    
    NSArray *btnArray = [NSArray arrayWithObjects:menuBarBtnItm, nil];
    [self.topToolBar setItems:btnArray animated:NO];
}

@end
