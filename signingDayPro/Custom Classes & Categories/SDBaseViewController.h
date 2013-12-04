//
//  SDBaseViewController.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDLoginViewController.h"
#import "NSObject+MasterUserMethods.h"
#import "GAITrackedViewController.h"

extern NSString * const SDKeyboardShouldHideNotification;

@class SDBaseViewController;
@class ActivityStory;



@interface SDBaseViewController : GAITrackedViewController <SDLoginViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *navigationTitle;

- (void)beginRefreshing;
- (void)endRefreshing;

- (void)hideProgressHudInView:(UIView *)view;
- (void)showProgressHudInView:(UIView *)view withText:(NSString *)text;

- (void)checkServer;

- (void)showAlertWithTitle:(NSString *)title andText:(NSString *)text;


- (void)playVideoWithActivityStory:(ActivityStory *)activityStory;
- (void)playVideoWithUrl:(NSURL *)url;
- (void)playVideoWithMediaFileUrlString:(NSString *)urlString;

@end
