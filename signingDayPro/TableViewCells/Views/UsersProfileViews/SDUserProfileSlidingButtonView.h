//
//  SDUserProfileSlidingButtonView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDProfileService.h"

@class SDUserProfileSlidingButtonView;

@protocol SDUserProfileSlidingButtonViewDelegate <NSObject>

@optional

- (void)userProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView
                      isNowFollowing:(BOOL)isFollowing;

- (void)staffButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)photosButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)videosButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)bioButtonPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)keyAttributesPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)offersPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)rosterPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)commitsPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;
- (void)contactsPressedInUserProfileSlidingButtonView:(SDUserProfileSlidingButtonView *)userProfileSlidingButtonView;

@end

@interface SDUserProfileSlidingButtonView : UIView

@property (nonatomic, weak) IBOutlet UILabel *followersCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic, assign) SDUserType userType;

@property (nonatomic, weak) id <SDUserProfileSlidingButtonViewDelegate> delegate;

- (void)setupView;

@end
