//
//  SDActivityFeedTableView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedTableView.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "SDActivityFeedCell.h"
#import "ActivityStory.h"
#import "User.h"

@interface SDActivityFeedTableView ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDActivityFeedTableView

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
    self.dataArray = nil;
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - activityFeed data source delegate

- (void)reloadTable
{
    [self reloadData];
}

#pragma mark - check server

- (void)checkServer
{
    [SDActivityFeedService getActivityStoriesForUser:self.user withDate:self.lastActivityStoryDate shouldDeleteOld:YES withSuccessBlock:^(NSDictionary *results){
        
        self.lastActivityStoryDate = [results objectForKey:@"LastDate"];
        
        if ([[results objectForKey:@"ResultCount"] intValue] == 0) {
            self.endReached = YES;
        }
        [self loadData];
        [self.tableDelegate shouldEndRefreshing];
    } failureBlock:^{
        [self.tableDelegate shouldEndRefreshing];
    }];
}

- (void)checkNewStories
{
    [SDActivityFeedService getActivityStoriesForUser:self.user withDate:nil shouldDeleteOld:NO withSuccessBlock:^(NSDictionary *results){
        
        BOOL listChanged = [[results valueForKey:@"ListChanged"] boolValue];
        if (listChanged) {
            [self loadData];
            [self.tableDelegate shouldEndRefreshing];
        }
        else {
            [self.tableDelegate shouldEndRefreshing];
        }
    } failureBlock:^{
        [self.tableDelegate shouldEndRefreshing];
    }];
}

#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.dataArray count]) {
        ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
        
        int contentHeight = [SDUtils heightForActivityStory:activityStory];
        int result = 114/*buttons images etc..*/ + contentHeight;
        
        return result;
    }
    else {
        return 60;
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (!self.endReached) {
        return [self.dataArray count] +1;
    }
    else {
        return [self.dataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.dataArray count]) {
        
        SDActivityFeedCell *cell = nil;
        NSString *cellIdentifier = @"ActivityFeedCellId";
        cell = (SDActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            // Load cell
            NSArray *topLevelObjects = nil;
            
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDActivityFeedCell" owner:nil options:nil];
            // Grab cell reference which was set during nib load:
            for(id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[SDActivityFeedCell class]]) {
                    cell = currentObject;
                    break;
                }
            }
        }
        
        ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
        [cell setupCellWithActivityStory:activityStory atIndexPath:indexPath];
        
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIActivityIndicatorViewStyle activityViewStyle = UIActivityIndicatorViewStyleGray;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.headerInfoDownloading) {
            [self checkServer];
        }
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.customHeaderView)
    {
        return self.customHeaderView;
    }
    else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 6)];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.customHeaderView)
    {
        return self.customHeaderView.frame.size.height;
    }
    else {
        return 6;
    }
}

#pragma mark - TableView delegate

- (void)loadData
{
    if (self.user) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", self.user];
        self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    else {
        self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }

    [self reloadTable];
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
