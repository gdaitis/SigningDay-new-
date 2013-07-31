//
//  SDUserProfileHeaderView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseProfileHeaderView.h"
#import "SDUserProfileHeaderDelegate.h"


@interface SDUserProfileMemberHeaderView : SDBaseProfileHeaderView

@property (nonatomic, strong) id <SDUserProfileHeaderDelegate> delegate;

@end
