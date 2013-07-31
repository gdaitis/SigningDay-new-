//
//  SDActivityFeedTableView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDTableView.h"
#import "SDActivityFeedDataSource.h"

@class SDActivityFeedTableView;

@protocol SDActivityFeedTableViewDelegate

- (void)shouldEndRefreshing;

@end

@class User;

@interface SDActivityFeedTableView : SDTableView <UITableViewDataSource,UITableViewDelegate,SDActivityFeedDataSourceDelegate>

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSDate *lastActivityStoryDate;
@property (nonatomic, assign) BOOL endReached;
@property (nonatomic, assign) int activityStoryCount;

@property (nonatomic, strong) id <SDActivityFeedTableViewDelegate> tableDelegate;

- (void)checkServer;
- (void)checkNewStories;

@end
