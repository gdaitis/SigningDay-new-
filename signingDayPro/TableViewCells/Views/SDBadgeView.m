//
//  SDBadgeView.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/27/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBadgeView.h"

@implementation SDBadgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)setBadgeCountNumber:(NSInteger)badgeCountNumber
{
    _badgeCountNumber = badgeCountNumber;
    
    for (UIView *subiew in self.subviews) {
        [subiew removeFromSuperview];
    }
    
    if (badgeCountNumber == 0)
        return;
    
    CGSize originalBadgeSize = CGSizeMake(14, 14);
    int horizontalPadding = 5;
    int verticalPadding = 1;
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *string = [NSString stringWithFormat:@"%d", self.badgeCountNumber];
    label.text = string;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    
    int width = originalBadgeSize.width;
    int height = originalBadgeSize.height;
    
    if (label.frame.size.width > originalBadgeSize.width - horizontalPadding * 2) {
        width = label.frame.size.width + horizontalPadding * 2;
    }
    if (label.frame.size.height > originalBadgeSize.height - verticalPadding * 2) {
        height = label.frame.size.height + verticalPadding * 2;
    }
    
    UIImage *image = [[UIImage imageNamed:@"badgeBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 2, 3, 2)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    backgroundImageView.frame = CGRectMake(0, 0, width, height);
    self.frame = backgroundImageView.frame;
    
    [self addSubview:backgroundImageView];
    [self addSubview:label];
    [label setCenter:self.center];
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
