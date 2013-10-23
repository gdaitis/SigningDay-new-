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

#import "SDGroupCell.h"
#import "SDForumCell.h"
#import "SDThreadCell.h"

#import "Group.h"
#import "Forum.h"
#import "Thread.h"

@interface SDForumListController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int result = 0;
    switch (self.listType) {
        case LIST_TYPE_GROUP:
            result = 100;
            break;
        case LIST_TYPE_FORUM:
            result = 60;
            break;
        case LIST_TYPE_THREAD:
            result = 60;
            break;
        default:
            break;
    }
    
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id result = nil;
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
    SDForumListController *forumListController = [[SDForumListController alloc] initWithNibName:@"SDBaseViewController" bundle:nil];
    forumListController.parentItem = parentItem;
    forumListController.listType = listType;
    
    [self.navigationController pushViewController:forumListController animated:YES];
}

- (void)showDiscussionControllerForThread:(Thread *)thread
{
    SDDiscussionViewController *discussionController = [[SDDiscussionViewController alloc] initWithNibName:@"SDBaseViewController" bundle:nil];
    discussionController.currentThread = thread;
    
    [self.navigationController pushViewController:discussionController animated:YES];
}


#pragma mark - data loading

- (void)loadGroupList
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataArray = [Group MR_findAllInContext:context];
    [self.tableView reloadData];
    
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    [SDWarRoomService getWarRoomGroupsWithCompletionBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        self.dataArray = [Group MR_findAllInContext:context];
        [self.tableView reloadData];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
    
}

- (void)loadForumList
{
    NSNumber *groupIdentifier = ((Group *)self.parentItem).identifier;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group.identifier == %@", groupIdentifier];
    
    self.dataArray = [Forum MR_findAllWithPredicate:predicate inContext:context];
    [self.tableView reloadData];
    
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    [SDWarRoomService getGroupForumsWithGroupId:groupIdentifier pageIndex:0 pageSize:20 completionBlock:^(NSInteger totalCount) {
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group.identifier == %@", groupIdentifier];
        
        self.dataArray = [Forum MR_findAllWithPredicate:predicate inContext:context];
        [self.tableView reloadData];
        [self hideProgressHudInView:self.view];
        
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
}

- (void)loadThreadList
{
    NSNumber *forumIdentifier = ((Forum *)self.parentItem).identifier;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forum.identifier == %@", forumIdentifier];
    
    self.dataArray = [Thread MR_findAllWithPredicate:predicate inContext:context];
    [self.tableView reloadData];
    
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    [SDWarRoomService getForumThreadsWithForumId:forumIdentifier pageIndex:0 pageSize:20 completionBlock:^(NSInteger totalCount) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forum.identifier == %@", forumIdentifier];
        
        self.dataArray = [Thread MR_findAllWithPredicate:predicate inContext:context];
        [self.tableView reloadData];
        [self hideProgressHudInView:self.view];
        
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
}


@end
