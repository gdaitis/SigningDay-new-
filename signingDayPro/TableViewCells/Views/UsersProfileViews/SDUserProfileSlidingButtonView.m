//
//  SDUserProfileSlidingButtonView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileSlidingButtonView.h"
#import "UIView+NibLoading.h"
#import <QuartzCore/QuartzCore.h>

@interface SDUserProfileSlidingButtonView ()

@property (nonatomic, weak) CAGradientLayer *shadowLayer;

@property (nonatomic, weak) IBOutlet UILabel *followersTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingTitleLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

//Sliding menu labels

@property (nonatomic, weak) IBOutlet UILabel *photosLabel;
@property (nonatomic, weak) IBOutlet UILabel *videosLabel;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;


@end

@implementation SDUserProfileSlidingButtonView


#pragma mark - initializers
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder
{
    if ([[self subviews] count] == 0) {
        SDUserProfileSlidingButtonView* theRealThing = (id)[SDUserProfileSlidingButtonView loadInstanceFromNib];
        theRealThing.frame = self.frame;
        theRealThing.autoresizingMask = self.autoresizingMask;
        theRealThing.alpha = self.alpha;
        
        return theRealThing;
    }
    return self;
}

#pragma mark - View setup

- (void)layoutSubviews
{
    [self setupView];
    
    UIView *lineView = [self.bottomView viewWithTag:999];
    if (lineView) {
        [lineView removeFromSuperview];
    }
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bottomView.frame.size.width, 1)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    bottomLineView.tag = 999;
    [self.bottomView addSubview:bottomLineView];
    
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    
    if (!self.shadowLayer) {
        CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
        float y = 0;
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
//            y = 20;
        newShadow.frame = CGRectMake(0, 1 + y, self.bottomView.frame.size.width, 4);
        newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
        self.shadowLayer = newShadow;
        [self.bottomView.layer addSublayer:self.shadowLayer];
    }
    
    [super layoutSubviews];
//    _scrollView.contentSize = CGSizeMake(375, 10);
    [self updateContentSize];
}

- (void)updateContentSize
{
    int lastButtonEndPlusOffset = _bioButton.frame.origin.y+_bioButton.frame.size.width+15;
    self.scrollView.contentSize = CGSizeMake(lastButtonEndPlusOffset, 10);
    NSLog(@"lastButtonEndPlusOffset = %d",lastButtonEndPlusOffset);
}

- (void)setupView
{
    [_bioButton addTarget:self action:@selector(bioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_changingButton addTarget:self action:@selector(changingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_staffButton addTarget:self action:@selector(staffButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_photosButton addTarget:self action:@selector(photosButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_videosButton addTarget:self action:@selector(videoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _followersCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:11.0];
    _followingCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:11.0];
}

#pragma mark - Follow button presses

- (void)followButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    [self.delegate userProfileSlidingButtonView:self
                                 isNowFollowing:sender.selected];
}

- (void)bioButtonPressed:(id)sender
{
    [self.delegate bioButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)changingButtonPressed:(id)sender
{
    [self.delegate changingButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)photosButtonPressed:(id)sender
{
    [self.delegate photosButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)videoButtonPressed:(id)sender
{
    [self.delegate videosButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)staffButtonPressed:(id)sender
{
    [self.delegate staffButtonPressedInUserProfileSlidingButtonView:self];
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
