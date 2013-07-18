//
//  SDViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileViewController.h"
#import "SDMenuViewController.h"
#import "SDProfileService.h"
#import "SDUserProfileHeaderView.h"
#import "SDTableView.h"
#import "User.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "SDActivityFeedCell.h"
#import "ActivityStory.h"
#import "SDActivityFeedCellContentView.h"
#import "SDImageService.h"
#import "AFNetworking.h"

#define kUserProfileHeaderHeight 360
#define kUserProfileHeaderHeightWithBuzzButtonView 450


@interface SDUserProfileViewController () <NSFetchedResultsControllerDelegate>
{
    BOOL _isMasterProfile;
}

@property (nonatomic, strong) IBOutlet SDTableView *tableView;
@property (atomic, strong) NSArray *dataArray;
@property (nonatomic, strong) SDUserProfileHeaderView *headerView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation SDUserProfileViewController

#pragma mark - Getters/Setters

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ActivityStory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"createdDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", _currentUser];
    [fetchRequest setPredicate:predicate];
    
//    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

#pragma mark - View loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //chechking if user is view his own profile, depending on this we show or remove buzz button view
    if ([_currentUser.identifier isEqualToNumber:[self getMasterIdentifier]]) {
        _isMasterProfile = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadActivityFeedInfo];
}


#pragma mark - ActivityStories data loading/displaying

- (void)loadActivityFeedInfo
{
    [self showProgressHudInView:self.view withText:@"Loading"];
    [SDActivityFeedService getActivityStoriesForUser:_currentUser withSuccessBlock:^{
        [self reloadActivityData];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
}

-(void)reloadActivityData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", _currentUser];
    self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO withPredicate:predicate];
    [self.tableView reloadData];
}



//-(void)reloadActivityData
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", _currentUser];
//        self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO withPredicate:predicate];
//
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            [self performSelector:@selector(reloadTable) withObject:nil afterDelay:<#(NSTimeInterval)#>];
//		});
//	});
//}

//-(void)reloadActivityData
//{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"author == %@", _currentUser];
//    [self fetchResultsUsingPredicate:predicate completionHandler:^(NSArray *data) {
//        self.dataArray = data;
//    }];
//}
//
//-(void)fetchResultsUsingPredicate:(NSPredicate *)predicate completionHandler:(void (^)(NSArray *data))completionHandler
//{    
//    dispatch_queue_t coreDataQueue = dispatch_queue_create("com.coredata.queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(coreDataQueue, ^{
//        NSArray *result = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO withPredicate:predicate];
//        
//        if(completionHandler != nil)
//        {
//            completionHandler(result);
//        }
//    });
//}

#pragma mark - TableView datasource

- (void)setupHeaderView
{
    if (_isMasterProfile) {
        _headerView.buzzButtonView.hidden = YES;
    }
    else {
        _headerView.buzzButtonView.hidden = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
//    id  sectionInfo =
//    [[_fetchedResultsController sections] objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _isMasterProfile ? kUserProfileHeaderHeight : kUserProfileHeaderHeightWithBuzzButtonView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_headerView) {
        // Load headerview
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDUserProfileHeaderView" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDUserProfileHeaderView class]]) {
                self.headerView = currentObject;
                break;
            }
        }
        [self setupHeaderView];
    }
    
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
    
    int contentHeight = [SDUtils heightForActivityStory:activityStory];
    int result = 120/*buttons images etc..*/ + contentHeight;
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    } else {
        [cell.thumbnailImageView cancelImageRequestOperation];
    }
    
    cell.likeButton.tag = indexPath.row;
    cell.commentButton.tag = indexPath.row;
    
    ActivityStory *activityStory = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likes count]];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.comments count]];
    cell.nameLabel.text =activityStory.author.name;
    [cell.resizableActivityFeedView setActivityStory:activityStory];
    
    if ([activityStory.author.avatarUrl length] > 0) {
        [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:activityStory.author.avatarUrl]];
    }
    
    cell.postDateLabel.text = [SDUtils formatedTimeForDate:activityStory.createdDate];
    cell.yearLabel.text = @"- DE, 2014";
    
    return cell;
}

#pragma mark UITableView delegate mothods

@end
