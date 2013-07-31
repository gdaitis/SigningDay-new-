//
//  SDActivityFeedDataSource.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDActivityFeedDataSource,User;

@protocol SDActivityFeedDataSourceDelegate <NSObject>

- (void)reloadTable;
- (void)shouldEndRefreshing;

@end

@interface SDActivityFeedDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) User *user;
@property (nonatomic, assign) int activityStoryCount;
@property (nonatomic, strong) NSDate *lastActivityStoryDate;
@property (nonatomic, assign) BOOL endReached;
@property (nonatomic, strong) id <SDActivityFeedDataSourceDelegate> delegate;

- (void)checkServer;
- (void)checkNewStories;

@end
