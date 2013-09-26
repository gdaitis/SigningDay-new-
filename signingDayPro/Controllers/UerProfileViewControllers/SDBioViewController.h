//
//  SDBioViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class User;

@interface SDBioViewController : SDBaseViewController

@property (nonatomic, strong) User *currentUser;

@end
