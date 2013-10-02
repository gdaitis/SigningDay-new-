//
//  SDActivityFeedTableView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDTableView.h"

@class SDActivityFeedTableView;
@class ActivityStory;

@protocol SDActivityFeedTableViewDelegate

@required
- (void)activityFeedTableViewShouldEndRefreshing:(SDActivityFeedTableView *)activityFeedTableView;
- (void)activityFeedTableView:(SDActivityFeedTableView *)activityFeedTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withActivityStory:(ActivityStory *)activityStory;

@optional

- (void)activityFeedTableView:(SDActivityFeedTableView *)activityFeedTableView wantsNavigateToController:(UIViewController *)viewController;

@end

@class User;

@interface SDActivityFeedTableView : SDTableView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSDate *lastActivityStoryDate;
@property (nonatomic, assign) BOOL endReached;
@property (nonatomic, assign) BOOL headerInfoDownloading;
@property (nonatomic, assign) int activityStoryCount;
@property (nonatomic, assign) int fetchLimit;

@property (nonatomic, strong) UIView *customHeaderView;

@property (nonatomic, strong) id <SDActivityFeedTableViewDelegate> tableDelegate;

- (void)checkServerAndDeleteOld:(BOOL)deleteOld;
- (void)loadData;

@end
