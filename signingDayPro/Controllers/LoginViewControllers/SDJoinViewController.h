//
//  SDJoinViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

typedef enum {
    SDJoinControllerCellUserType_FAN = 0,
    SDJoinControllerCellUserType_PARENT = 1,
    SDJoinControllerCellUserType_PLAYER = 2,
    SDJoinControllerCellUserType_COACH= 3,
    SDJoinControllerCellUserType_HIGHSCHOOL = 4
} SDJoinControllerCellUserType;

@class SDJoinViewController;

@protocol SDJoinViewControllerDelegate <NSObject>

- (void)bakcPressedInJoinViewController:(SDJoinViewController *)joinViewController;

@end

@interface SDJoinViewController : SDBaseViewController

@property (nonatomic, assign) id <SDJoinViewControllerDelegate> delegate;

@end
