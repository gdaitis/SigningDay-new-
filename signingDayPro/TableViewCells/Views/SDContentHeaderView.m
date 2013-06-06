//
//  SDContentHeaderView.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDContentHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SDContentHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.textLabel.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.textLabel];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        bottomLineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:bottomLineView];
        
        CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
        CGColorRef lightColor = [UIColor clearColor].CGColor;
        
        CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
        newShadow.frame = CGRectMake(0, frame.size.height, frame.size.width, 2);
        newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
        
        [self.layer addSublayer:newShadow];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
