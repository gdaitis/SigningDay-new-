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
        
        [self addSubview:self.textLabel];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        bottomLineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:bottomLineView];
        
        CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
        CGColorRef lightColor = [UIColor clearColor].CGColor;
        
        CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
        
        newShadow.frame = CGRectMake(0, frame.size.height, frame.size.width, 4);
        newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
        
        [self.layer addSublayer:newShadow];
    }
    return self;
}

- (UILabel *)textLabel
{
    if (_textLabel)
        return _textLabel;
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:15];
    _textLabel.backgroundColor = [UIColor whiteColor];
    
    return _textLabel;
}

- (void)setTextLabel:(UILabel *)textLabel
{
    _textLabel = textLabel;
}

@end
