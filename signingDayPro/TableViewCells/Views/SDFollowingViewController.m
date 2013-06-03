//
//  SDFollowingViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/31/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDFollowingViewController.h"
#import "Master.h"
#import "User.h"
#import "SDAppDelegate.h"
#import "SDFollowingCell.h"
#import "SDFollowingService.h"

@interface SDFollowingViewController ()

@property (nonatomic, strong) NSMutableSet *userSet;

@property (nonatomic, weak) UIButton *followersButton;
@property (nonatomic, weak) UIButton *followingButton;


- (void)followButtonPressed:(UIButton *)sender;

@end

@implementation SDFollowingViewController

- (NSMutableSet *)userSet
{
    if (_userSet == nil) {
        _userSet = [[NSMutableSet alloc] init];
    }
    return _userSet;
}

- (id)init
{
    self = [super initWithNibName:@"SDBaseToolbarItemViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _controllerType = CONTROLLER_TYPE_FOLLOWERS;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        SDFollowingCell *cell = (SDFollowingCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userImageView.image = nil;
    }
}

- (void)loadInfo
{
    NSNumber *masterID = [self getMasterIdentifier];
    [self showProgressHudInView:self.view withText:@"Updating following list"];
    
    //get list of followers
    [SDFollowingService getListOfFollowersForUserWithIdentifier:masterID withCompletionBlock:^{
        //get list of followings
        [SDFollowingService getListOfFollowingsForUserWithIdentifier:masterID withCompletionBlock:^{
            //refresh the view
            [self reloadView];
            [self hideProgressHudInView:self.view];
        } failureBlock:^{
            [self reloadView];
            [self hideProgressHudInView:self.view];
        }];
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
    }];
}

- (void)reloadView
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSPredicate *masterUsernamePredicate = nil;
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        masterUsernamePredicate = [NSPredicate predicateWithFormat:@"following.username like %@", username];
    }
    else {
        if (self.userSet.count > 0) {
            masterUsernamePredicate = [NSPredicate predicateWithFormat:@"identifier IN %@ OR followedBy.username like %@",self.userSet,  username];
        }
        else {
            masterUsernamePredicate = [NSPredicate predicateWithFormat:@"followedBy.username like %@", username];
        }
    }
    
    self.dataArray = [User MR_findAllSortedBy:@"username" ascending:YES withPredicate:masterUsernamePredicate];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kBaseToolbarItemViewControllerHeaderHeight)];
    view.backgroundColor = [UIColor whiteColor];
    
    //adding gray line in the center
    UIView *middleLineview = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 1, kBaseToolbarItemViewControllerHeaderHeight)];
    middleLineview.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:middleLineview];
    
    UIView *bottomLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 39, self.view.bounds.size.width, 1)];
    bottomLineview.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:bottomLineview];
    

    //adding followers button
    UIButton *followersbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    followersbtn.frame = CGRectMake(0, 0, 160, kBaseToolbarItemViewControllerHeaderHeight);
    [followersbtn setTitle:@"Followers" forState:UIControlStateNormal];
    [followersbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [followersbtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [followersbtn addTarget:self action:@selector(followTypeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    self.followersButton = nil;
    self.followersButton = followersbtn;    
    [view addSubview:_followersButton];
    
    
    //adding following button
    UIButton *followingbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    followingbtn.frame = CGRectMake(160, 0, 160, kBaseToolbarItemViewControllerHeaderHeight);
    [followingbtn setTitle:@"Following" forState:UIControlStateNormal];
    [followingbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [followingbtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [followingbtn addTarget:self action:@selector(followTypeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    self.followingButton = nil;
    self.followingButton = followingbtn;
    [view addSubview:_followingButton];
    
    
    //decide which button to selecte
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        _followersButton.selected = YES;
    }
    else {
        _followingButton.selected = YES;
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *followingCellID = @"FollowingCellID";
    SDFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:followingCellID];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDFollowingCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (SDFollowingCell *) currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            }
        }
        [cell.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.followButton.tag = indexPath.row;
    cell.userImageView.image = nil;
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    cell.usernameTitle.text = user.name;
    cell.userImageUrlString = user.avatarUrl;
    
    //check for following
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    if ([user.followedBy isEqual:master]) {
        cell.followButton.selected = YES;
    }
    else {
        cell.followButton.selected = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 1)];
    result.backgroundColor = [UIColor clearColor];
    
    return result;
}

#pragma mark - Following actions

- (void)followButtonPressed:(UIButton *)sender
{
    [self showProgressHudInView:self.view withText:@"Updating following list"];
    
    User *user = [self.dataArray objectAtIndex:sender.tag];
    [self.userSet addObject:user.identifier];
    
    if (!sender.selected) {
        //following action
        [SDFollowingService followUserWithIdentifier:user.identifier withCompletionBlock:^{
            [self hideProgressHudInView:self.view];
            [self loadInfo];
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
    else {
        //unfollowing action
        [SDFollowingService unfollowUserWithIdentifier:user.identifier withCompletionBlock:^{
            [self hideProgressHudInView:self.view];
            [self loadInfo];
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
}

- (void)followTypeChanged:(UIButton *)btn
{
    if (!btn.selected) {
        _userSet = nil;
        [SDFollowingService deleteUnnecessaryUsers];
        
        if ([btn isEqual:_followersButton]) {
            _controllerType = CONTROLLER_TYPE_FOLLOWERS;
            _followingButton.selected = NO;
        }
        else {
            _controllerType = CONTROLLER_TYPE_FOLLOWING;
            _followersButton.selected = NO;
        }
        btn.selected = YES;
        [self reloadView];
    }
}

@end
