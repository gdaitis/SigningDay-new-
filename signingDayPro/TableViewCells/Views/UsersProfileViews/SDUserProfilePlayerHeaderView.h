//
//  SDUserProfilePlayerHeaderView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseProfileHeaderView.h"
#import "SDUserProfileHeaderDelegate.h"

@class User;

@interface SDUserProfilePlayerHeaderView : SDBaseProfileHeaderView

@property (nonatomic, strong) id <SDUserProfileHeaderDelegate> delegate;

@end
