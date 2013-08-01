//
//  SDLikesViewController.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/31/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDLikesViewController.h"
#import "SDFollowingCell.h"
#import "AFNetworking.h"
#import "User.h"
#import "Master.h"
#import "SDFollowingService.h"
#import "ActivityStory.h"

@interface SDLikesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDLikesViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadInfo];
}

- (void)loadInfo
{
    // load from core data
    // check server
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
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
    } else {
        [cell.userImageView cancelImageRequestOperation];
    }
    
    cell.followButton.tag = indexPath.row;
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    cell.usernameTitle.text = user.name;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:nil
                                 cropedForSize:CGSizeMake(50, 50)
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           SDFollowingCell *cell = (SDFollowingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                           cell.userImageView.image = image;
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           //
                                       }];
    
    //check for following
    Master *master = [self getMaster];
    
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
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 1)];
    result.backgroundColor = [UIColor clearColor];
    
    return result;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    NSLog(@"user id = %d",[user.identifier intValue]);
}

#pragma mark - Following actions

- (void)followButtonPressed:(UIButton *)sender
{
    [self showProgressHudInView:self.tableView withText:@"Updating following list"];
    
    User *user = [self.dataArray objectAtIndex:sender.tag];
    
    if (!sender.selected) {
        //following action
        [SDFollowingService followUserWithIdentifier:user.identifier withCompletionBlock:^{
            [self hideProgressHudInView:self.tableView];
            [self loadInfo];
        } failureBlock:^{
            [self hideProgressHudInView:self.tableView];
        }];
    }
    else {
        //unfollowing action
        [SDFollowingService unfollowUserWithIdentifier:user.identifier withCompletionBlock:^{
            [self hideProgressHudInView:self.tableView];
            [self loadInfo];
        } failureBlock:^{
            [self hideProgressHudInView:self.tableView];
        }];
    }
}

@end
