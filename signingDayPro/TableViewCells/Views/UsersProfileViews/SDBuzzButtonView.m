//
//  SDBuzzButtonView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBuzzButtonView.h"
#import "UIView+NibLoading.h"

@interface SDBuzzButtonView ()

- (IBAction)messageButtonPressed:(id)sender;
- (IBAction)buzzButtonPressed:(id)sender;

@end

@implementation SDBuzzButtonView

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
        SDBuzzButtonView *buzzButtonView = (id)[SDBuzzButtonView loadInstanceFromNib];
        buzzButtonView.frame = self.frame;
        buzzButtonView.autoresizingMask = self.autoresizingMask;
        buzzButtonView.alpha = self.alpha;
        
        return buzzButtonView;
    }
    return self;
}

#pragma mark - actions

- (IBAction)buzzButtonPressed:(id)sender
{
    [_delegate buzzSomethingButtonPressedInButtonView:self];
}

- (IBAction)messageButtonPressed:(id)sender
{
    [_delegate messageButtonPressedInButtonView:self];
}

@end
