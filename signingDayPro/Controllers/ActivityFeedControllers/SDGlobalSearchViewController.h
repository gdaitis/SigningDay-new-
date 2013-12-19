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
@class User;

@protocol SDGlobalSearchViewControllerDelegate <NSObject>

@optional

- (void)globalSearchViewController:(SDGlobalSearchViewController *)globalSearchViewController
                     didSelectUser:(User *)user;

@end

@interface SDGlobalSearchViewController : SDBaseViewController

@property (nonatomic, weak) id <SDGlobalSearchViewControllerDelegate> delegate;

@end
