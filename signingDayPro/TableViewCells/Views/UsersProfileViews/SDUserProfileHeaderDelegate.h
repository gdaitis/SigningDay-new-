//
//  SDUserProfileHeaderDelegate.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/31/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol SDUserProfileHeaderDelegate <NSObject>

- (void)dataLoadingFinishedInHeaderView:(id)headerView;
- (void)dataLoadingFailedInHeaderView:(id)headerView;

- (void)headerView:(id)headerView didSelectSchoolUser:(User *)schoolUser;

@end
