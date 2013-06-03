//
//  SDFollowingViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/31/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseToolbarItemViewController.h"

typedef enum {
    
	CONTROLLER_TYPE_FOLLOWING = 0,
	CONTROLLER_TYPE_FOLLOWERS
} ControllerType;

@interface SDFollowingViewController : SDBaseToolbarItemViewController

@property (nonatomic, assign) ControllerType controllerType;

- (void)loadInfo;

@end
