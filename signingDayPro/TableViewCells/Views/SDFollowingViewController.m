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
#import "SDContentHeaderView.h"
#import "AFNetworking.h"
#import "UIImage+Crop.h"
#import <QuartzCore/QuartzCore.h>
#import "SDUserProfileViewController.h"
#import "UIImageView+Crop.h"

@interface SDFollowingViewController ()

@property (nonatomic, strong) NSMutableSet *userSet;
@property (nonatomic, assign) BOOL searchActive;

@property (nonatomic, weak) UIButton *followersButton;
@property (nonatomic, weak) UIButton *followingButton;

//Pagination properties/ to keep track of the current page ant etc.
@property (nonatomic, assign) int totalFollowers;
@property (nonatomic, assign) int totalFollowings;
@property (nonatomic, assign) int currentFollowersPage;
@property (nonatomic, assign) int currentFollowingPage;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *customSearchDisplayController;

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
//    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _controllerType = CONTROLLER_TYPE_FOLLOWERS;
    _currentFollowersPage = _currentFollowingPage = 0;

    SDContentHeaderView *header = [[SDContentHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, kBaseToolbarItemViewControllerHeaderHeight)];
    
    //adding gray line in the center
    UIView *middleLineview = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 1, kBaseToolbarItemViewControllerHeaderHeight)];
    middleLineview.backgroundColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
    [header addSubview:middleLineview];
    
    //adding followers button
    UIButton *followersbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    followersbtn.frame = CGRectMake(0, 0, 160, kBaseToolbarItemViewControllerHeaderHeight);
    [followersbtn setTitle:@"Followers" forState:UIControlStateNormal];
    [followersbtn setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1] forState:UIControlStateNormal];
    [followersbtn setTitleColor:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1] forState:UIControlStateSelected];
    followersbtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [followersbtn addTarget:self action:@selector(followTypeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    self.followersButton = nil;
    self.followersButton = followersbtn;
    [header addSubview:_followersButton];
    
    //adding following button
    UIButton *followingbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    followingbtn.frame = CGRectMake(160, 0, 160, kBaseToolbarItemViewControllerHeaderHeight);
    [followingbtn setTitle:@"Following" forState:UIControlStateNormal];
    [followingbtn setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1] forState:UIControlStateNormal];
    [followingbtn setTitleColor:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1] forState:UIControlStateSelected];
    followingbtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [followingbtn addTarget:self action:@selector(followTypeChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar = searchBar;
    _searchBar.delegate = self;
    [_searchBar sizeToFit];
    _searchBar.tintColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:218.0f/255.0f alpha:1.0f];
    [self.view addSubview:_searchBar];
    
    CGRect frame = _searchBar.frame;
    frame.origin.y = header.frame.origin.y + header.frame.size.height;
    _searchBar.frame = frame;
    
    // Add lines
    CGColorRef upperBorderColor = [UIColor lightGrayColor].CGColor;
    CGColorRef lowerBorderColor = [UIColor lightGrayColor].CGColor;
    
    CALayer *upperBorderLayer = [CALayer layer];
    upperBorderLayer.frame = CGRectMake(0, -1, 320, 1);
    upperBorderLayer.borderWidth = 1;
    upperBorderLayer.borderColor = upperBorderColor;
    [self.tableView.layer addSublayer:upperBorderLayer];

    CALayer *lowerBorderLayer = [CALayer layer];
    lowerBorderLayer.frame = CGRectMake(0, _searchBar.frame.size.height, 320, 1);
    lowerBorderLayer.borderWidth = 1;
    lowerBorderLayer.borderColor = lowerBorderColor;
    [_searchBar.layer addSublayer:lowerBorderLayer];
    
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc]
                                                          initWithSearchBar:_searchBar contentsController:self];
    
    self.customSearchDisplayController = searchDisplayController;
    
    self.customSearchDisplayController.delegate = self;
    self.customSearchDisplayController.searchResultsDataSource = self;
    self.customSearchDisplayController.searchResultsDelegate = self;
    
//    self.tableView.tableHeaderView = _searchBar;
    
    self.followingButton = nil;
    self.followingButton = followingbtn;
    [header addSubview:_followingButton];
    
    //decide which button to selecte
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        _followersButton.selected = YES;
    }
    else {
        _followingButton.selected = YES;
    }
    
    [self.view addSubview:header];
    
    [self.refreshControl removeFromSuperview];
    
    frame = self.tableView.frame;
    frame.origin.y = _searchBar.frame.origin.y + _searchBar.frame.size.height;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.tableView.frame = frame;
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
    [self updateInfoAndShowActivityIndicator:YES];
}

#pragma mark - filter & info update

- (void)updateInfoAndShowActivityIndicator:(BOOL)showActivityIndicator
{
    Master *master = [self getMaster];
    
    if (showActivityIndicator) {
        [self showProgressHudInView:self.view withText:@"Updating list"];
    }
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWING) {
        //get list of followings
        [SDFollowingService getListOfFollowingsForUserWithIdentifier:master.identifier forPage:_currentFollowingPage withCompletionBlock:^(int totalFollowingCount) {
            //refresh the view
            _totalFollowings = totalFollowingCount;
            [self hideProgressHudInView:self.view];
            [self reloadView];
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
    else {
        //get list of followers
        [SDFollowingService getListOfFollowersForUserWithIdentifier:master.identifier forPage:_currentFollowersPage withCompletionBlock:^(int totalFollowerCount) {
            _totalFollowers = totalFollowerCount; //set the count to know how much we should send
            [self hideProgressHudInView:self.view];
            [self reloadView];
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
}

- (void)loadMoreData
{
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        _currentFollowersPage ++;
    }
    else {
        _currentFollowingPage ++;
    }
    
    //already showing activity indicator in last cell so no need for the MBProgressHUD
    [self updateInfoAndShowActivityIndicator:NO];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.dataArray = nil;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    
    NSPredicate *masterUsernamePredicate = nil;
    int fetchLimit = 0;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        masterUsernamePredicate = [NSPredicate predicateWithFormat:@"following.username like %@", username];
        fetchLimit = (_currentFollowersPage +1) *kMaxItemsPerPage;
        
    }
    else {
        fetchLimit = (_currentFollowingPage +1) *kMaxItemsPerPage;
        
        if (self.userSet.count > 0) {
            masterUsernamePredicate = [NSPredicate predicateWithFormat:@"identifier IN %@ OR followedBy.username like %@",self.userSet,  username];
        }
        else {
            masterUsernamePredicate = [NSPredicate predicateWithFormat:@"followedBy.username like %@", username];
        }
    }
    
    if ([searchText isEqual:@""]) {
        //seting fetch limit for pagination
        NSFetchRequest *request = [User MR_requestAllWithPredicate:masterUsernamePredicate inContext:context];
        [request setFetchLimit:fetchLimit];
        //set sort descriptor
        
        NSString *sortingKey = nil;
        if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
            sortingKey = @"followerRelationshipCreated";
        }
        else {
            sortingKey = @"followingRelationshipCreated";
        }
        
        NSSortDescriptor *followingSortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:NO selector:@selector(compare:)];
        [request setSortDescriptors:[NSArray arrayWithObjects:followingSortDescriptor, /*nameSortDescriptor,*/ nil]];
        self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    }
    else {
        
        NSFetchRequest *request = [User MR_requestAllWithPredicate:masterUsernamePredicate inContext:context];
        [request setFetchLimit:fetchLimit];
        //set sort descriptor
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSPredicate *usernameSearchPredicate = [NSPredicate predicateWithFormat:@"username contains[cd] %@ OR name contains[cd] %@", searchText, searchText];
        NSArray *predicatesArray = [NSArray arrayWithObjects:masterUsernamePredicate, usernameSearchPredicate, nil];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
        [request setPredicate:predicate];
        
        self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    }
    [self reloadTableView];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    int result = [self.dataArray count];
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        
        if ((_currentFollowersPage+1)*kMaxItemsPerPage < _totalFollowers ) {
            if (result > 0)
            {
                if ([_searchBar.text length] == 0) {
                    result ++;
                }
                else
                {
                    if (_searchActive) {
                        //search active, we show loading indicator at bottom
                        result++;
                    }
                }
            }
            else {
                if (_searchActive) {
                    //search active, we show loading indicator at bottom
                    result++;
                }
            }
        }
    }
    else {
        if ((_currentFollowingPage+1)*kMaxItemsPerPage < _totalFollowings ) {
            if (result > 0)
            {
                if ([_searchBar.text length] == 0) {
                    result ++;
                }
                else
                {
                    if (_searchActive) {
                        //search active, we show loading indicator at bottom
                        result++;
                    }
                }
            }
            else {
                if (_searchActive) {
                    //search active, we show loading indicator at bottom
                    result++;
                }
            }
        }
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.dataArray count]) {
        static NSString *followingCellID = @"FollowingCellID";
        SDFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:followingCellID];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDFollowingCell" owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                    cell = (SDFollowingCell *) currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = [UIColor clearColor];
                    break;
                }
            }
        } else {
            [cell.userImageView cancelImageRequestOperation];
        }
        [cell.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIActivityIndicatorViewStyle activityViewStyle = UIActivityIndicatorViewStyleWhite;
        
        if ([_searchBar.text length] > 0) {
            activityViewStyle = UIActivityIndicatorViewStyleGray;
        }
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        if (!_searchActive) {
            [self loadMoreData];
        }
        
        return cell;
    }
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
    [self.delegate followingViewController:self didSelectUser:user];
}

#pragma mark - Following actions

- (void)followButtonPressed:(UIButton *)sender
{
    [self hideKeyboard];
    [self showProgressHudInView:self.view withText:@"Updating following list"];
    
    User *user = [self.dataArray objectAtIndex:sender.tag];
    [self.userSet addObject:user.identifier];
    
    if (!sender.selected) {
        //following action
        [SDFollowingService followUserWithIdentifier:user.identifier withCompletionBlock:^{
            [self hideProgressHudInView:self.view];
            [self loadInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FollowingUpdated" object:nil];
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
    else {
        //unfollowing action
        [SDFollowingService unfollowUserWithIdentifier:user.identifier withCompletionBlock:^{
            [self hideProgressHudInView:self.view];
            [self loadInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FollowingUpdated" object:nil];
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
}

- (void)followTypeChanged:(UIButton *)btn
{
    _searchBar.text = @"";
    [self.searchDisplayController setActive:NO animated:YES];
    
    if (!btn.selected) {
        
        _userSet = nil;
        if ([btn isEqual:_followersButton]) {
            _controllerType = CONTROLLER_TYPE_FOLLOWERS;
            _followingButton.selected = NO;
        }
        else {
            _controllerType = CONTROLLER_TYPE_FOLLOWING;
            _followersButton.selected = NO;
        }
        btn.selected = YES;
        _currentFollowingPage = _currentFollowersPage = _totalFollowings = _totalFollowers = 0;
        [self updateInfoAndShowActivityIndicator:YES];
    }
}


- (void)reloadTableView
{
    if ([_searchBar.text length] > 0) {
        
        //reload searchresultstableview tu update cell
        [_customSearchDisplayController.searchResultsTableView reloadData];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)reloadView
{
    if ([_searchBar.text length] > 0) {
        [self filterContentForSearchText:_searchBar.text];
    }
    else {
        [self filterContentForSearchText:@""];
    }
}

- (void)hideKeyboard
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}

#pragma mark - UISearchDisplayController delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchActive = YES;
    //filter users in local DB
    [self filterContentForSearchText:searchString];
    
    Master *master = [self getMaster];
    
    if (_controllerType == CONTROLLER_TYPE_FOLLOWERS) {
        
        if ((_currentFollowersPage+1)*kMaxItemsPerPage < _totalFollowers ) { //if all users are already downloaded we do not need additional call to webservice
            
            [SDFollowingService getListOfFollowersForUserWithIdentifier:master.identifier withSearchString:searchString withCompletionBlock:^{
                _searchActive = NO;
                //in case later request will finish first, use _searchBar.text
                [self filterContentForSearchText:_searchBar.text];
            } failureBlock:^{
                _searchActive = NO;
                [self reloadTableView];
            }];
        }
    }
    else {
        if ((_currentFollowingPage+1)*kMaxItemsPerPage < _totalFollowings ) { //if all users are already downloaded we do not need additional call to webservice
            
            [SDFollowingService getListOfFollowingsForUserWithIdentifier:master.identifier withSearchString:searchString withCompletionBlock:^{
                _searchActive = NO;
                //in case later request will finish first, use _searchBar.text
                [self filterContentForSearchText:_searchBar.text];
            } failureBlock:^{
                _searchActive = NO;
                [self reloadTableView];
            }];
        }
    }
    
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self reloadView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SDFollowingCell" bundle:nil] forCellReuseIdentifier:@"FollowingCellID"];
}

@end
