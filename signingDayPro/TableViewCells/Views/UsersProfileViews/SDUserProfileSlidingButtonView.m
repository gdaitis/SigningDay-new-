//
//  SDUserProfileSlidingButtonView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileSlidingButtonView.h"
#import "UIView+NibLoading.h"

@interface SDUserProfileSlidingButtonView ()

@property (nonatomic, weak) IBOutlet UILabel *followersTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingTitleLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation SDUserProfileSlidingButtonView



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
        SDUserProfileSlidingButtonView* theRealThing = (id)[self loadInstanceFromNib];
        theRealThing.frame = self.frame;
        theRealThing.autoresizingMask = self.autoresizingMask;
        theRealThing.alpha = self.alpha;
        
        return theRealThing;
    }
    return self;
}

- (void)layoutSubviews
{
    [self setupView];
    [super layoutSubviews];
    _scrollView.contentSize = CGSizeMake(375, 10);
}

- (void)setupView
{
    [_bioButton addTarget:self action:@selector(bioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _followersCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:11.0];
    _followingCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:11.0];
}

#pragma mark - Follow button presses

- (void)followButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (void)bioButtonPressed:(id)sender
{
    
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
