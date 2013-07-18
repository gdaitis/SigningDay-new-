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

@property (nonatomic, weak) IBOutlet UIButton *buzzButton;
@property (nonatomic, weak) IBOutlet UIButton *messageButton;

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
        SDBuzzButtonView* theRealThing = (id)[self loadInstanceFromNib];
        theRealThing.frame = self.frame;
        theRealThing.autoresizingMask = self.autoresizingMask;
        theRealThing.alpha = self.alpha;
        
        return theRealThing;
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
