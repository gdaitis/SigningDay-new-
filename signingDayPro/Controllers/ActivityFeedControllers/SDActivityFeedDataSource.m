//
//  SDActivityFeedDataSource.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedDataSource.h"
#import "SDActivityFeedService.h"
#import "SDActivityFeedCell.h"
#import "ActivityStory.h"
#import "User.h"
#import "SDUtils.h"

@interface SDActivityFeedDataSource ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDActivityFeedDataSource

#pragma mark - check server

- (void)checkServer
{
    [SDActivityFeedService getActivityStoriesForUser:nil withDate:self.lastActivityStoryDate withSuccessBlock:^(NSDictionary *results){
        
        int resultCount = [[results objectForKey:@"ResultCount"] intValue];
        self.activityStoryCount += resultCount;
        self.lastActivityStoryDate = [results objectForKey:@"LastDate"];
        
        if (resultCount == 0) {
            self.endReached = YES;
        }
        [self loadData];
        [self.delegate shouldEndRefreshing];
    } failureBlock:^{
        [self.delegate shouldEndRefreshing];
    }];
}

- (void)checkNewStories
{
    [SDActivityFeedService getActivityStoriesForUser:nil withDate:nil withSuccessBlock:^(NSDictionary *results){
        
        BOOL listChanged = [[results valueForKey:@"ListChanged"] boolValue];
        if (listChanged) {
            
            self.activityStoryCount = [[results objectForKey:@"ResultCount"] intValue];
            self.lastActivityStoryDate = [results objectForKey:@"LastDate"];
            self.endReached = NO;
            [self loadData];
            [self.delegate shouldEndRefreshing];
        }
        else {
            [self.delegate shouldEndRefreshing];
        }
    } failureBlock:^{
        [self.delegate shouldEndRefreshing];
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
        UIActivityIndicatorViewStyle activityViewStyle = UIActivityIndicatorViewStyleWhite;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self checkServer];
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 6)];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6;
}

#pragma mark - TableView delegate

- (void)loadData
{
    self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [self.delegate reloadTable];
}

@end
