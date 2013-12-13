//
//  SDGlobalSearchViewController.h
//  SigningDay
//
//  Created by lite on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class SDGlobalSearchViewController;

@protocol SDGlobalSearchViewControllerDelegate <NSObject>

@optional

@end

@interface SDGlobalSearchViewController : SDBaseViewController

@property (nonatomic, weak) id <SDGlobalSearchViewControllerDelegate> delegate;

@end
