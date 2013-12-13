//
//  SDTopSchoolsViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

typedef enum {
    TABLE_STYLE_EDIT  = 0,
    TABLE_STYLE_NORMAL  = 1
} TableEditStyle;

@class User;

@interface SDTopSchoolsViewController : SDBaseViewController

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, assign) TableEditStyle tableStyle;

@end

