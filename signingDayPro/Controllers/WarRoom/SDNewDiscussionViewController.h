//
//  SDNewDiscussionViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 06/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseViewController.h"

@class Forum;
@class Thread;
@class SDNewDiscussionViewController;

@protocol SDNewDiscussionViewControllerDelegate <NSObject>

@optional

- (void)newDiscussionViewController:(SDNewDiscussionViewController *)newDiscussionViewController
                 didCreateNewThread:(Thread *)thread;

@end

@interface SDNewDiscussionViewController : SDBaseViewController

@property (nonatomic, strong) Forum *forum;
@property (nonatomic, weak) id <SDNewDiscussionViewControllerDelegate> delegate;

@end
