//
//  SDStarsRatingView.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDStarsRatingView.h"

@implementation SDStarsRatingView

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
    self.frame = CGRectMake(0, 0, 67, 11);
    self.backgroundColor = [UIColor clearColor];
    self.starsCount = 0;
}

- (void)setStarsCount:(NSInteger)starsCount
{
    _starsCount = starsCount;
    
    for (UIView *subiew in self.subviews) {
        [subiew removeFromSuperview];
    }
    
    UIImage *activeStarImage = [UIImage imageNamed:@"UserProfileStarActive.png"];
    UIImage *fadedStarImage= [UIImage imageNamed:@"UserProfileStarFaded.png"];
    
    int space = 3;
    int starWidth = 11;
    
    for (int i = 0; i < 5; i++) {
        int x = (starWidth + space) * i;
        UIImageView *starImageView;
        if (starsCount < (i+1))
            starImageView = [[UIImageView alloc] initWithImage:fadedStarImage];
        else
            starImageView = [[UIImageView alloc] initWithImage:activeStarImage];
        
        starImageView.frame = CGRectMake(x, 0, starImageView.frame.size.width, starImageView.frame.size.height);
        
        [self addSubview:starImageView];
    }
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
