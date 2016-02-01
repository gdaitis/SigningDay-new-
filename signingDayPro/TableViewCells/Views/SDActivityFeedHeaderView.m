//
//  SDActivityFeedHeaderView.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/10/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedHeaderView.h"

@implementation SDActivityFeedHeaderView

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
    // Background
    UIImage *bgImage = [UIImage imageNamed:@"activity_feed_header_bg@2x.png"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgImageView.frame = CGRectMake(0, 0, 320, 40);
    [self addSubview:bgImageView];
    
    // Buttons
    UIImage *buzzSomethingImage = [UIImage imageNamed:@"buzz_something_button@2x.png"];
    UIImage *addMediaImage = [UIImage imageNamed:@"add_media_button@2x.png"];
    
    UIButton *buzzSomethingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buzzSomethingButton.frame = CGRectMake(0, 0, 160, 40);
    [buzzSomethingButton setBackgroundImage:buzzSomethingImage
                                   forState:UIControlStateNormal];
    [buzzSomethingButton addTarget:self
                            action:@selector(buzzSomethingPressed)
                  forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addMediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addMediaButton.frame = CGRectMake(160, 0, 160, 40);
    [addMediaButton setBackgroundImage:addMediaImage
                              forState:UIControlStateNormal];
    [addMediaButton addTarget:self
                       action:@selector(addMediaPressed)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:buzzSomethingButton];
    [self addSubview:addMediaButton];
}

- (void)buzzSomethingPressed
{
    [self.delegate activityFeedHeaderViewDidClickOnBuzzSomething:self];
}

- (void)addMediaPressed
{
    [self.delegate activityFeedHeaderViewDidClickOnAddMedia:self];
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
