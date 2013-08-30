//
//  SDActivityStoryViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 8/29/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class ActivityStory;

@interface SDActivityStoryViewController : SDBaseViewController

@property (nonatomic, strong) ActivityStory *activityStory;

@end
