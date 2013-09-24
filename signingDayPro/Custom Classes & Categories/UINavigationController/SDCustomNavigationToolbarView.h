//
//  SDCustomNavigationToolbarView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SDCustomNavigationToolbarView;

@protocol SDCustomNavigationToolbarViewDelegate <NSObject>

@optional

- (void)leftButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView;
- (void)rightButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView;
- (void)notificationButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView;
- (void)conversationButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView;
- (void)followerButtonPressedInToolbarView:(SDCustomNavigationToolbarView *)toolbarView;

@end


@interface SDCustomNavigationToolbarView : UIView

@property (nonatomic, weak) IBOutlet UIButton *notificationButton;
@property (nonatomic, weak) IBOutlet UIButton *messagesButton;
@property (nonatomic, weak) IBOutlet UIButton *followersButton;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) id <SDCustomNavigationToolbarViewDelegate> delegate;


- (void)setLeftButtonImage:(UIImage *)image;
- (void)setrightButtonImage:(UIImage *)image;

@end
