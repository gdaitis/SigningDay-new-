//
//  SDSearchHeader.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDSearchHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+AddTitle.h"

const float kSDSearchHeaderSpaceBetweenOptionButtons = 9;
const float kSDSearchHeaderSpaceBetweenOptionButtonAndSearchButton = 10;
const float kSDSearchHeaderTopMargin = 8;
const float kSDSearchHeaderBottomMargin = 15;
const float kSDSearchHeaderLeftMargin = 11;

@implementation SDSearchHeader

- (void)setupView
{
    self.backgroundColor = [UIColor colorWithRed:223.0f/255.0f
                                           green:223.0f/255.0f
                                            blue:223.0f/255.0f
                                           alpha:1.0f];
    
    // adding shadow
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    newShadow.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 4);
    newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
    
    [self.layer addSublayer:newShadow];
    
    // bottom line
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 189, 320, 1)];
    bottomLine.backgroundColor = [UIColor colorWithRed:168.0f/255.0f
                                                 green:168.0f/255.0f
                                                  blue:168.0f/255.0f
                                                 alpha:1.0f];
    [self addSubview:bottomLine];
}

- (UIImage *)searchOptionButtonBgImage
{
    return [UIImage imageNamed:@"SearchOptionButtonBg.png"];
}

- (UIImage *)searchButtonBigImage
{
    return [UIImage imageNamed:@"SearchButtonBig.png"];
}

- (UIButton *)searchButtonWithBackgroundImage:(UIImage *)backgroundImage
                                       action:(SEL)action
                                      yOrigin:(float)yOrigin
                                        title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:backgroundImage
                      forState:UIControlStateNormal];
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(kSDSearchHeaderLeftMargin,
                              yOrigin,
                              backgroundImage.size.width,
                              backgroundImage.size.height);
    if (title)
        [button setCustomTitle:title];
    
    return button;
}

@end
