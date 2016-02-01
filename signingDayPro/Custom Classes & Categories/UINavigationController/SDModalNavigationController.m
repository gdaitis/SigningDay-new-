//
//  SDModalNavigationController.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDModalNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SDModalNavigationController ()

@end

@implementation SDModalNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSDictionary *textTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithRed:55.0/255.0 green:48.0/255.0 blue:8.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                         [UIColor colorWithRed:238.0/255.0 green:209.0/255.0 blue:39.0/255.0 alpha:1.0], UITextAttributeTextShadowColor,
                                         [NSValue valueWithUIOffset:UIOffsetMake(1, 1)], UITextAttributeTextShadowOffset,
                                         [UIFont fontWithName:@"BebasNeue" size:23.0], UITextAttributeFont,
                                         nil];
    self.navigationBar.titleTextAttributes = textTitleAttributes;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"ToolbarBg.png"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationBar setTitleVerticalPositionAdjustment:-1 forBarMetrics:UIBarMetricsDefault];
    
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    CGFloat navigationBarBottom;
    navigationBarBottom = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        navigationBarBottom = navigationBarBottom + 20;
    
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    newShadow.frame = CGRectMake(0, navigationBarBottom, self.view.frame.size.width, 4);
    newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
    
    [self.view.layer addSublayer:newShadow];
}

- (void)closePressed
{
    [self.myDelegate modalNavigationControllerWantsToClose:self];
}


@end
