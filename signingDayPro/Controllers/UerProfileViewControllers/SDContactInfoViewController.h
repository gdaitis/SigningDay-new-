//
//  SDContactInfoViewController.h
//  SigningDay
//
//  Created by lite on 05/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class User;

@interface SDContactInfoViewController : SDBaseViewController

@property (nonatomic, strong) User *currentUser;

@end
