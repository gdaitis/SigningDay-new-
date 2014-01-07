//
//  SDBaseUserSearchViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 1/7/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDBaseViewController.h"
#import "SDProfileService.h"

@class SDCantFindYourselfView;

@interface SDCommonUserSearchViewController : SDBaseViewController

@property (nonatomic, assign) SDUserType userType;
@property (nonatomic, strong) UISearchDisplayController *customSearchDisplayController;

#pragma mark - Data Loading

- (void)loadLocalDbDataWithString:(NSString *)searchString;
- (void)checkServer;

@end
