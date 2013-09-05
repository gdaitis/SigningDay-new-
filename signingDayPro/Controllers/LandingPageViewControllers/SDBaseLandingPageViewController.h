//
//  SDBaseLandingPageViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

@interface SDBaseLandingPageViewController : SDBaseViewController

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int currentUserCount;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) UIView *searchBarBackground;

- (void)hideFilterView;
- (void)showFilterView;

@end
