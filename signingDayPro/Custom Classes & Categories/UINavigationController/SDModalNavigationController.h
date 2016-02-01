//
//  SDModalNavigationController.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNavigationController.h"

@class SDModalNavigationController;

@protocol SDModalNavigationControllerDelegate <NSObject>

@optional

- (void)modalNavigationControllerWantsToClose:(SDModalNavigationController *)modalNavigationController;

@end

@interface SDModalNavigationController : /*SDNavigationController*/ UINavigationController

@property (nonatomic, strong) id <SDModalNavigationControllerDelegate> myDelegate;

- (void)closePressed;

@end
