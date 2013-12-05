//
//  SDCollegeSearchViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@class SDCollegeSearchViewController;
@class User;

@protocol SDCollegeSearchViewControllerDelegate <NSObject>

@optional
- (void)collegeSearchViewController:(SDCollegeSearchViewController *)collegeSearchController didSelectCollegeUser:(User *)teamUser;

@end


@interface SDCollegeSearchViewController : SDBaseViewController

@property (nonatomic, weak) id <SDCollegeSearchViewControllerDelegate> delegate;

@end
