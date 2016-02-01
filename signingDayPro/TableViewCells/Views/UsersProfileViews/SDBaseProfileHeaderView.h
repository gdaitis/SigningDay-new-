//
//  SDBaseProfileHeaderView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"
#import "SDImageService.h"
#import "SDBuzzButtonView.h"
#import "SDUserProfileSlidingButtonView.h"
#import "SDUserProfileHeaderDelegate.h"

@interface SDBaseProfileHeaderView : UIView <SDBuzzButtonViewDelegate, SDUserProfileSlidingButtonViewDelegate>

@property (nonatomic, strong) IBOutlet SDUserProfileSlidingButtonView *slidingButtonView;
@property (nonatomic, strong) IBOutlet SDBuzzButtonView *buzzButtonView;

@property (nonatomic, strong) id <SDUserProfileHeaderDelegate> delegate;

- (void)setupInfoWithUser:(User *)user;
- (void)hideBuzzButtonView:(BOOL)hide;
- (void)updateFollowingInfo;

@end
