//
//  SDGlobalSearchViewController.m
//  SigningDay
//
//  Created by lite on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDGlobalSearchViewController.h"
#import "SDProfileService.h"
#import "User.h"
#import "SDBasicUserCell.h"
#import "UIView+NibLoading.h"
#import "UIImageView+AFNetworking.h"

@interface SDGlobalSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation SDGlobalSearchViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillLayoutSubviews
{
    self.searchBar.frame = CGRectMake(0,
                                      0,
                                      self.view.frame.size.width,
                                      40);
    
    [self.view addSubview:self.searchBar];
    
    self.tableView.frame = CGRectMake(0,
                                      self.searchBar.frame.size.height,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height - self.searchBar.frame.size.height);
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.searchBar becomeFirstResponder];
}

#pragma mark - Data loading

- (void)reloadLocalData
{
    NSString *searchText = [self.searchBar text];
    if ([searchText isEqual:@""]) {
        self.searchResults = nil;
    } else {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSPredicate *usernameSearchPredicate = [NSPredicate predicateWithFormat:@"username contains[cd] %@ OR name contains[cd] %@", searchText, searchText];
        self.searchResults = [User MR_findAllSortedBy:@"name"
                                            ascending:YES
                                        withPredicate:usernameSearchPredicate
                                            inContext:context];
    }
    
    [self.tableView reloadData];
}

- (void)checkServer
{
    [SDProfileService searchForUsersWithSearchString:self.searchBar.text
                                     completionBlock:^{
                                         [self reloadLocalData];
                                         [self endRefreshing];
                                     } failureBlock:^{
                                         [self endRefreshing];
                                     }];
}

#pragma mark - UISearchBarDelegateMethods

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchResults = nil;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self beginRefreshing];
    [self checkServer];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDCoachingStaffCellID";
    SDBasicUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (SDBasicUserCell *)[SDBasicUserCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    User *user = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.verifiedImageView.hidden = ([user.accountVerified boolValue]) ? NO : YES;
    
    cell.nameLabel.text = user.name;
    cell.positionLabel.text = user.bioAddress;
    
    [cell.imgView cancelImageRequestOperation];
    cell.imgView.image = nil;
    [cell.imgView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.searchResults objectAtIndex:indexPath.row];
    [self.searchBar resignFirstResponder];
    [self.delegate globalSearchViewController:self
                                didSelectUser:user];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
