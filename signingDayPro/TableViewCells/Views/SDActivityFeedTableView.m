//
//  SDActivityFeedTableView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedTableView.h"
#import "User.h"

@interface SDActivityFeedTableView () <SDActivityFeedDataSourceDelegate>

@property (nonatomic, strong) SDActivityFeedDataSource *activityFeedDataSource;

@end

@implementation SDActivityFeedTableView

#pragma mark - setters 

- (void)setLastActivityStoryDate:(NSDate *)lastActivityStoryDate
{
    _lastActivityStoryDate = lastActivityStoryDate;
    self.activityFeedDataSource.lastActivityStoryDate = lastActivityStoryDate;
}

- (void)setEndReached:(BOOL)endReached
{
    _endReached = endReached;
    self.activityFeedDataSource.endReached = endReached;
}

- (void)setActivityStoryCount:(int)activityStoryCount
{
    _activityStoryCount = activityStoryCount;
    self.activityFeedDataSource.activityStoryCount = activityStoryCount;
}

#pragma mark - initializers

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupDelegates];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupDelegates];
    }
    return self;
}

- (void)setupDelegates
{
    if (!self.activityFeedDataSource) {
        self.activityFeedDataSource = [[SDActivityFeedDataSource alloc] init];
        self.activityFeedDataSource.delegate = self;
    }
    self.delegate = self.activityFeedDataSource;
    self.dataSource = self.activityFeedDataSource;
}

- (void)loadInfo
{
    if (self.user) {
        
        self.activityFeedDataSource.user = self.user;
    }
    [self reloadData];
}

- (void)checkServer
{
    [self.activityFeedDataSource checkServer];
}

- (void)checkNewStories
{
    [self.activityFeedDataSource checkNewStories];
}


#pragma mark - activityFeed data source delegate

- (void)reloadTable
{
    [self reloadData];
}

- (void)shouldEndRefreshing
{
    //delegate about refresh end
    [self.tableDelegate shouldEndRefreshing];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
