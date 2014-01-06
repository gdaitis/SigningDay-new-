//
//  SDJoinViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class SDJoinViewController;

@protocol SDJoinViewControllerDelegate <NSObject>

- (void)bakcPressedInJoinViewController:(SDJoinViewController *)joinViewController;

@end

@interface SDJoinViewController : SDBaseViewController

@property (nonatomic, assign) id <SDJoinViewControllerDelegate> delegate;

@end
