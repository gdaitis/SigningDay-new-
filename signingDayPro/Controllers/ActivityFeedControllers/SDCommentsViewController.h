//
//  SDCommentsViewController.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/29/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseChatViewController.h"

@class ActivityStory;

@interface SDCommentsViewController : SDBaseChatViewController

@property (nonatomic, strong) ActivityStory *activityStory;

@end
