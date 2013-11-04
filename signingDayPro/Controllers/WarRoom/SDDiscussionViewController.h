//
//  SDDiscussionViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseChatViewController.h"

@class Thread;

@interface SDDiscussionViewController : SDBaseChatViewController

@property (nonatomic, strong) Thread *currentThread;

@end
