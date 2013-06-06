//
//  SDMessageViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseToolbarItemViewController.h"

@class SDMessageViewController;
@class Conversation;

@protocol SDMessageViewControllerDelegate <NSObject>

@optional

- (void)messageViewController:(SDMessageViewController *)messageViewController didSelectConversation:(Conversation *)conversation;

@end

@interface SDMessageViewController : SDBaseToolbarItemViewController

@property (nonatomic, weak) id <SDMessageViewControllerDelegate> delegate;

- (void)loadInfo;

@end
