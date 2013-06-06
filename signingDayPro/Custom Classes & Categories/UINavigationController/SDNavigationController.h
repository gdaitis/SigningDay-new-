//
//  SDNavigationController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/27/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDMessageViewController.h"

#define kTriangleViewTag 999
#define kTopToolbarHeight 44

@interface SDNavigationController : UINavigationController <SDMessageViewControllerDelegate>

@property (nonatomic, weak) UIButton *menuButton;

@end
