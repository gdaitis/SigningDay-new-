//
//  SDUserProfilePlayerHeaderView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDUserProfileSlidingButtonView.h"
#import "SDBuzzButtonView.h"

@class User;

@interface SDUserProfilePlayerHeaderView : UIView

@property (nonatomic, strong) IBOutlet SDUserProfileSlidingButtonView *slidingButtonView;
@property (nonatomic, strong) IBOutlet SDBuzzButtonView *buzzButtonView;

- (void)setupInfoWithUser:(User *)user;
- (void)hideBuzzButtonView:(BOOL)hide;

@end
