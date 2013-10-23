//
//  SDWarRoomsListController.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/21/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDGroupListController.h"
#import "SDWarRoomService.h"
#import "SDDiscussionListViewController.h"
#import "UIView+NibLoading.h"
#import "SDGroupCell.h"

@interface SDGroupListController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDGroupListController

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
    
#warning testing
    self.dataArray = [NSArray arrayWithObjects:@"ONE FOR TESTING", nil];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.group) {
        
        if ([self.group objectForKey:@"subgroup"])
            [self showWarromListControllerWithGroup:[self.dataArray objectAtIndex:indexPath.row]];
        else {
            SDDiscussionListViewController *discussionListController = [[SDDiscussionListViewController alloc] initWithNibName:@"SDBaseViewController" bundle:[NSBundle mainBundle]];
            
            [self.navigationController pushViewController:discussionListController animated:YES];
        }
    }
    else {
        [self showWarromListControllerWithGroup:[self.dataArray objectAtIndex:indexPath.row]];
    }
}

- (void)showWarromListControllerWithGroup:(id)group
{
    UIStoryboard *warRoomStoryboard = [UIStoryboard storyboardWithName:@"WarRoomStoryBoard"
                                                                bundle:nil];
    
    SDGroupListController *groupListController = [warRoomStoryboard instantiateViewControllerWithIdentifier:@"WarRoomController"];
    groupListController.group = group;
    
    [self.navigationController pushViewController:groupListController animated:YES];
}


#pragma mark - data loading

- (void)loadData
{
    if (self.group)
        [self loadGroup];
    else
        [self loadSubGroup];
}

- (void)loadGroup
{
    [SDWarRoomService getWarRoomsWithCompletionBlock:^{
//        self.dataArray =
        [self.tableView reloadData];
    } failureBlock:^{

    }];
}

- (void)loadSubGroup
{
//    [SDWarRoomService getGroupWithId:[self.group valueForKey:@"identifier"]
//                 withCompletionBlock:^{
//
//    [self.tableView reloadData];
//    } failureBlock:^{
//        
//    }];
}


@end
