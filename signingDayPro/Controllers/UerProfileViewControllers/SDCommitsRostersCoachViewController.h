//
//  SDCommitsRostersViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 10/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

typedef enum {
    CONTROLLER_TYPE_ROSTERS = 0,
    CONTROLLER_TYPE_COMMITS,
    CONTROLLER_TYPE_COACHINGSTAFF
} ControllerListType;

@interface SDCommitsRostersCoachViewController : SDBaseViewController

@property (nonatomic,assign) ControllerListType controllerType;
@property (nonatomic, strong) NSString *userIdentifier;

//year string for commits(teams only)
@property (nonatomic, strong) NSString *yearString;

@end
