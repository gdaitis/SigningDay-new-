//
//  UIButton+AddTitle.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "UIButton+AddTitle.h"

@implementation UIButton (AddTitle)

- (void)setCustomTitle:(NSString *)title
{
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(5, 10, 0, 0)];
    
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithRed:98.0f/255.0f
                                        green:98.0f/255.0f
                                         blue:98.0f/255.0f
                                        alpha:1.0f]
               forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
}

@end
