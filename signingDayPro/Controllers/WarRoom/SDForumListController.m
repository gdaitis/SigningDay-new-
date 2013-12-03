//
//  SDWarRoomsListController.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/21/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDForumListController.h"
#import "SDWarRoomService.h"
#import "SDDiscussionViewController.h"
#import "UIView+NibLoading.h"
#import "SDModalNavigationController.h"
#import "SDNewDiscussionViewController.h"
#import "SDGoogleAnalyticsService.h"

#import "SDGroupCell.h"
#import "SDForumCell.h"
#import "SDThreadCell.h"

#import "Group.h"
#import "Forum.h"
#import "Thread.h"

#define kForumPageSize 20

@interface SDForumListController () <UITableViewDataSource, UITableViewDelegate, SDModalNavigationControllerDelegate, SDNewDiscussionViewControllerDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int pagingItemCount;
@property (nonatomic, assign) BOOL pagingEndReached;
@property (nonatomic, assign) BOOL dataDownloadInProgress;

@end

@implementation SDForumListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.pagingItemCount = 0;
    self.pagingEndReached = NO;
    
    //    [self beginRefreshing];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.listType == LIST_TYPE_THREAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPostButtonPressed)
                                                     name:kNewPostButtonPressedNotification
                                                   object:nil];
        [((SDNavigationController *)self.navigationController) addNewPostButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.listType == LIST_TYPE_THREAD) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kNewPostButtonPressedNotification
                                                      object:nil];
        [((SDNavigationController *)self.navigationController) removeNewPostButton];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    switch (self.listType) {
        case LIST_TYPE_GROUP:
            [[SDGoogleAnalyticsService sharedService] trackAppViewWithName:@"Forum group screen"];
            break;
        case LIST_TYPE_FORUM:
            [[SDGoogleAnalyticsService sharedService] trackAppViewWithName:@"Forum screen"];
            break;
        case LIST_TYPE_THREAD:
            [[SDGoogleAnalyticsService sharedService] trackAppViewWithName:@"Forum thread screen"];
            break;
        default:
            break;
    }
}

- (void)checkServer
{
    self.pagingEndReached = NO;
    self.pagingItemCount = 0;
    [self downloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    switch (self.listType) {
        case LIST_TYPE_GROUP:
            [self loadGroupList];
            break;
        case LIST_TYPE_FORUM:
            [self loadForumList];
            break;
        case LIST_TYPE_THREAD:
            [self loadThreadList];
            break;
        default:
            break;
    }
}

- (void)downloadData
{
    switch (self.listType) {
        case LIST_TYPE_GROUP:
            [self downloadGroupList];
            break;
        case LIST_TYPE_FORUM:
            [self downloadForumList];
            break;
        case LIST_TYPE_THREAD:
            [self downloadThreadList];
            break;
        default:
            break;
    }
}

- (void)newPostButtonPressed
{
    SDModalNavigationController *modalNavigationViewController = [[SDModalNavigationController alloc] init];
    modalNavigationViewController.myDelegate = self;
    UIStoryboard *warRoomStoryboard = [UIStoryboard storyboardWithName:@"WarRoomStoryBoard"
                                                                bundle:nil];
    SDNewDiscussionViewController *createNewDiscussionNavigationController = [warRoomStoryboard instantiateViewControllerWithIdentifier:@"CreateNewDiscussionController"];
    createNewDiscussionNavigationController.delegate = self;
    Forum *forum = (Forum *)self.parentItem;
    createNewDiscussionNavigationController.forum = forum;
    [modalNavigationViewController addChildViewController:createNewDiscussionNavigationController];
    [self presentViewController:modalNavigationViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int result = (self.listType == LIST_TYPE_GROUP) ? 100 : 60;
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int result = 0;
    int dataCount = [self.dataArray count];
    
    if (self.listType != LIST_TYPE_GROUP)
        result = (self.pagingEndReached) ? dataCount : dataCount + 1;
    else
        result = dataCount;
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id result = nil;
    if (indexPath.row != [self.dataArray count]) {
        
        switch (self.listType) {
            case LIST_TYPE_GROUP:
            {
                NSString *identifier = @"SDGroupCellID";
                SDGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                
                if (!cell) {
                    cell = (id)[SDGroupCell loadInstanceFromNib];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = [UIColor clearColor];
                }
                
                id group = [self.dataArray objectAtIndex:indexPath.row];
                // Configure the cell...
                [cell setupCellWithGroup:group];
                
                result = cell;
                break;
            }
            case LIST_TYPE_FORUM:
            {
                NSString *identifier = @"SDForumCellID";
                SDForumCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                
                if (!cell) {
                    cell = (id)[SDForumCell loadInstanceFromNib];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = [UIColor clearColor];
                }
                
                id forum = [self.dataArray objectAtIndex:indexPath.row];
                [cell setupCellWithForum:forum];
                
                result = cell;
                break;
            }
            case LIST_TYPE_THREAD:
            {
                NSString *identifier = @"SDThreadCellID";
                SDThreadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                
                if (!cell) {
                    cell = (id)[SDThreadCell loadInstanceFromNib];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = [UIColor clearColor];
                }
                
                id thread = [self.dataArray objectAtIndex:indexPath.row];
                [cell setupCellWithThread:thread];
                
                result = cell;
            }
            default:
                break;
        }
    }
    else {
        NSString *identifier = @"PagingCellID";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        UIActivityIndicatorViewStyle activityViewStyle = UIActivityIndicatorViewStyleGray;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        if (!self.dataDownloadInProgress) {
            //data downloading not in progress, we can start downloading further pages
            [self downloadData];
        }
        result = cell;
    }
    
    return result;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (self.listType) {
        case LIST_TYPE_GROUP: {
            
            Group *group = [self.dataArray objectAtIndex:indexPath.row];
            [self showForumListControllerWithParentItem:group andListType:LIST_TYPE_FORUM];
            break;
        }
        case LIST_TYPE_FORUM:{
            
            Forum *forum = [self.dataArray objectAtIndex:indexPath.row];
            [self showForumListControllerWithParentItem:forum andListType:LIST_TYPE_THREAD];
            break;
        }
        case LIST_TYPE_THREAD: {
            Thread *thread = [self.dataArray objectAtIndex:indexPath.row];
            [self showDiscussionControllerForThread:thread];
            break;
        }
        default:
            break;
    }
}

- (void)showForumListControllerWithParentItem:(id)parentItem andListType:(GroupListType)listType
{
    SDForumListController *forumListController = [[SDForumListController alloc] initWithNibName:@"SDBaseViewController"
                                                                                         bundle:nil];
    forumListController.parentItem = parentItem;
    forumListController.listType = listType;
    
    [self.navigationController pushViewController:forumListController
                                         animated:YES];
}

- (void)showDiscussionControllerForThread:(Thread *)thread
{
    UIStoryboard *warRoomStoryboard = [UIStoryboard storyboardWithName:@"WarRoomStoryBoard"
                                                                bundle:nil];
    SDDiscussionViewController *discussionController = [warRoomStoryboard instantiateViewControllerWithIdentifier:@"DiscussionViewController"];
    discussionController.currentThread = thread;
    
    [self.navigationController pushViewController:discussionController
                                         animated:YES];
}


#pragma mark DATA LOADING
#pragma mark - Groups

- (void)downloadGroupList
{
    self.dataDownloadInProgress = YES;
    [SDWarRoomService getWarRoomGroupsWithCompletionBlock:^{
        self.dataDownloadInProgress = NO;
        [self getGroups];
        [self endRefreshing];
    } failureBlock:^{
        [self endRefreshing];
    }];
}

- (void)loadGroupList
{
    self.dataDownloadInProgress = YES;
    [self getGroups];
    [self downloadGroupList];
}

- (void)getGroups
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataArray = [Group MR_findAllSortedBy:@"name" ascending:YES inContext:context];
    [self.tableView reloadData];
}

#pragma mark - Forum

- (void)downloadForumList
{
    NSNumber *groupIdentifier = ((Group *)self.parentItem).identifier;
    self.dataDownloadInProgress = YES;
    [SDWarRoomService getGroupForumsWithGroupId:groupIdentifier pageIndex:self.pagingItemCount/kForumPageSize pageSize:kForumPageSize completionBlock:^(NSInteger totalCount) {
        
        self.pagingItemCount +=kForumPageSize;
        [self getForumsWithId:groupIdentifier];
        self.dataDownloadInProgress = NO;
        [self endRefreshing];
    } failureBlock:^{
        [self endRefreshing];
    }];
}

- (void)loadForumList
{
    NSNumber *groupIdentifier = ((Group *)self.parentItem).identifier;
    [self getForumsWithId:groupIdentifier];
    [self downloadForumList];
}

- (void)getForumsWithId:(NSNumber *)groupIdentifier
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group.identifier == %@", groupIdentifier];
    
    NSFetchRequest *request = [Forum MR_requestAllWithPredicate:predicate inContext:context];
    [request setFetchLimit:self.pagingItemCount];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.dataArray = [Forum MR_executeFetchRequest:request inContext:context];
    
    if ([self.dataArray count] < self.pagingItemCount) {
        self.pagingEndReached = YES;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Thread

- (void)downloadThreadList
{
    NSNumber *forumIdentifier = ((Forum *)self.parentItem).identifier;
    
    self.dataDownloadInProgress = YES;
    [SDWarRoomService getForumThreadsWithForumId:forumIdentifier pageIndex:self.pagingItemCount/kForumPageSize pageSize:kForumPageSize completionBlock:^(NSInteger totalCount) {
        
        self.pagingItemCount += kForumPageSize;
        self.dataDownloadInProgress = NO;
        [self endRefreshing];
        [self getThreadsWithId:forumIdentifier];
    } failureBlock:^{
        [self endRefreshing];
    }];
}

- (void)loadThreadList
{
    NSNumber *forumIdentifier = ((Forum *)self.parentItem).identifier;
    [self getThreadsWithId:forumIdentifier];
    [self downloadThreadList];
}

- (void)getThreadsWithId:(NSNumber *)forumIdentifier
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forum.identifier == %@", forumIdentifier];
    
    NSFetchRequest *request = [Thread MR_requestAllWithPredicate:predicate inContext:context];
    [request setFetchLimit:self.pagingItemCount];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.dataArray = [Thread MR_executeFetchRequest:request inContext:context];
    
    if ([self.dataArray count] < self.pagingItemCount) {
        self.pagingEndReached = YES;
    }
    
    [self.tableView reloadData];
}

#pragma mark - SDModalNavigationController myDelegate methods

- (void)modalNavigationControllerWantsToClose:(SDModalNavigationController *)modalNavigationController
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self beginRefreshing];
                                 [self checkServer];
                             }];
}

#pragma mark - SDNewDiscussionViewController delegate methods

- (void)newDiscussionViewController:(SDNewDiscussionViewController *)newDiscussionViewController
                 didCreateNewThread:(Thread *)thread
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self showDiscussionControllerForThread:thread];
                             }];
}

@end
