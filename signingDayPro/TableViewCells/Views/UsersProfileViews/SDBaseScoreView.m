//
//  SDBaseScoreView.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseScoreView.h"

@implementation SDBaseScoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupView];
}

- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    self.baseScore = 0;
}

- (void)setBaseScore:(float)baseScore
{
    _baseScore = baseScore;
    
    for (UIView *subiew in self.subviews) {
        [subiew removeFromSuperview];
    }
    
    UIImage *emptyBarImage = [UIImage imageNamed:@"UserProfileBaseScoreBarEmpty.png"];
    UIImage *fullBarImage = [UIImage imageNamed:@"UserProfileBaseScoreBarFull.png"];
    UIImage *halfFullBarImage = [UIImage imageNamed:@"UserProfileBaseScoreBarHalfFull.png"];
    
    int space = 1;
    int barWidth = 17;
    
    BOOL halfBarUsed = NO;
    
    for (int i = 0; i < 10; i++) {
        UIImageView *barImageView;
        if (baseScore < ((i+1)*10)) {
            float fractPart = baseScore - i*10;
            if (fractPart > 2 && halfBarUsed == NO) { // half-full bar
                barImageView = [[UIImageView alloc] initWithImage:halfFullBarImage];
                halfBarUsed = YES;
            } else { // empty bar
                barImageView = [[UIImageView alloc] initWithImage:emptyBarImage];
            }
        } else { // full bar
            barImageView = [[UIImageView alloc] initWithImage:fullBarImage];
        }
        
        int x = (barWidth + space) * i;
        barImageView.frame = CGRectMake(x, 0, barImageView.frame.size.width, barImageView.frame.size.height);
        
        [self addSubview:barImageView];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(185, -10, 40, 26)];
    label.text = [NSString stringWithFormat:@"%.02f", baseScore];
    label.font = [UIFont fontWithName:@"BebasNeue" size:15];
    label.textColor = [UIColor colorWithRed:247 green:222 blue:0 alpha:1];
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
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
