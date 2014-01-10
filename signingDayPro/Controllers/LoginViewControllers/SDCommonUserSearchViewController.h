//
//  SDBaseUserSearchViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 1/7/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDBaseViewController.h"
#import "SDProfileService.h"

@class User;

@interface SDCommonUserSearchViewController : SDBaseViewController

@property (nonatomic, assign) SDUserType userType;

- (void)checkServerForUsersWithNameSubstring:(NSString *)nameSubstring;
- (void)dataLoadedForSearchString:(NSString *)searchString;

- (void)claimAccount:(User *)user;
- (void)createNewAccount;
- (NSString *)addressTitleForUser:(User *)user;

@end
