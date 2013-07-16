//
//  SDBaseViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDLoginViewController.h"

@class Master;
@class User;

@interface SDBaseViewController : UIViewController <SDLoginViewControllerDelegate>

- (Master *)getMaster;
- (NSNumber *)getMasterIdentifier;
- (User *)getMasterUser;

- (void)showLoginScreen;

- (void)hideProgressHudInView:(UIView *)view;
- (void)showProgressHudInView:(UIView *)view withText:(NSString *)text;

@end
