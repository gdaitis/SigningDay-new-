//
//  SDCustomNavigationToolbarView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCustomNavigationToolbarView.h"

@interface SDCustomNavigationToolbarView ()

- (IBAction)buttonPressed:(id)sender;

@end

@implementation SDCustomNavigationToolbarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - View setup

- (void)setupView
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        
        //update constraints due to ios7 different button size eval.
        NSArray *constraints = [self constraints];
        if(constraints.count != 0){
            for (NSLayoutConstraint *constraint in constraints) {
                if (constraint.constant == 6.0) {
                    constraint.constant = 10;
                }
            }
            
        }
    }
}

- (void)setLeftButtonImage:(UIImage *)image
{
    [self.leftButton setImage:image forState:UIControlStateNormal];
}

- (void)setrightButtonImage:(UIImage *)image
{
    [self.rightButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)buttonPressed:(id)sender
{
    //disabling button for some time so animations could finish
    ((UIButton *)sender).userInteractionEnabled = NO;
    [self performSelector:@selector(enableButtonAfterDelay:) withObject:sender afterDelay:0.4];
    
    int tag = ((UIButton *)sender).tag;
    switch (tag) {
        case 1:
        {
            [self.delegate leftButtonPressedInToolbarView:self];
            break;
        }
        case 2:
        {
            [self.delegate notificationButtonPressedInToolbarView:self];
            break;
        }
        case 3:
        {
            [self.delegate conversationButtonPressedInToolbarView:self];
            break;
        }
        case 4:
        {
            [self.delegate followerButtonPressedInToolbarView:self];
            break;
        }
        case 5:
        {
            [self.delegate rightButtonPressedInToolbarView:self];
            break;
        }
        default:
            break;
    }
}

- (void)enableButtonAfterDelay:(UIButton *)sender
{
    sender.userInteractionEnabled = YES;
}

@end
