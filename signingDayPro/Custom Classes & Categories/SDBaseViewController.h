//
//  SDBaseViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

@class Master;

@interface SDBaseViewController : UIViewController

- (Master *)getMaster;
- (NSNumber *)getMasterIdentifier;

- (void)hideProgressHudInView:(UIView *)view;
- (void)showProgressHudInView:(UIView *)view withText:(NSString *)text;

@end
