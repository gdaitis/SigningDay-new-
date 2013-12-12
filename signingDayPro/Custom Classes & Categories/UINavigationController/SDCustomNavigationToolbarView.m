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
        [self setupView];
    }
    return self;
}

#pragma mark - View setup

- (void)setupView
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        self.backgroundImageView.image = [UIImage imageNamed:@"toolbarBgIphone5.png"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavigationBarBgIOS7.png"];
    }
}

- (void)setLeftButtonImage:(UIImage *)image
{
    [self.leftButton setImage:image forState:UIControlStateNormal];
}

- (void)setrightButtonImage:(UIImage *)image
{
    //button size changed depending on different images, also position is recalculated
    int offsetFromRightSide = 10;
    
    CGRect frame = self.rightButton.frame;
    frame.size.width = image.size.width;
    frame.origin.x = self.frame.size.width - image.size.width - offsetFromRightSide;
    self.rightButton.frame = frame;
    
    [self.rightButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)buttonPressed:(id)sender
{
    //disabling button for some time so animations could finish
    ((UIButton *)sender).userInteractionEnabled = NO;
    [self performSelector:@selector(enableButtonAfterDelay:) withObject:sender afterDelay:0.6];
    
    [self.delegate anyButtonPressedInToolbarView:self];
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
