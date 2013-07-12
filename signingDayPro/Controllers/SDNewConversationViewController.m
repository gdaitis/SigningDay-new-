//
//  SDNewConversationViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/10/12.
//
//

#import "SDNewConversationViewController.h"
#import "User.h"
#import "SDImageService.h"
#import "SDChatService.h"
#import "Master.h"
#import "SDNavigationController.h"
#import "SDLoginService.h"
#import "UIImage+Crop.h"
#import "SDNewConversationCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "SDConversationViewController.h"
#import "SDFollowingService.h"

@interface SDNewConversationViewController ()

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL searchActive;

//Pagination properties to keep track of the current page ant etc.
@property (nonatomic, assign) int totalFollowers;
@property (nonatomic, assign) int currentFollowersPage;

- (void)filterContentForSearchText:(NSString*)searchText;

@end

@implementation SDNewConversationViewController

@synthesize searchResults = _searchResults;
@synthesize searchBar     = _searchBar;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentFollowersPage = 0;
    
//    UIImage *image = [UIImage imageNamed:@"x_button_yellow.png"];
//    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
//    UIButton *button = [[UIButton alloc] initWithFrame:frame];
//    [button setBackgroundImage:image forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = barButton;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg.png"]];
    [imageView setFrame:self.tableView.bounds];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:121.0f/255.0f green:121.0f/255.0f blue:121.0f/255.0f alpha:1.0f]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self updateInfoAndShowActivityIndicator:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SDFollowingService removeFollowing:YES andFollowed:YES];
}

- (void)didReceiveMemoryWarning
{
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        SDNewConversationCell *cell = (SDNewConversationCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userImageView.image = nil;
    }
    [super didReceiveMemoryWarning];
}

- (void)userDidLogout
{
    self.searchResults = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - filter & info update

- (void)updateInfoAndShowActivityIndicator:(BOOL)showActivityIndicator
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    if (showActivityIndicator) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Updating list";
    }
    
    //get list of followers
    [SDFollowingService getAlphabeticallySortedListOfFollowersForUserWithIdentifier:master.identifier forPage:_currentFollowersPage withCompletionBlock:^(int totalFollowerCount) {
        _totalFollowers = totalFollowerCount; //set the count to know how much we should send
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self reloadView];
    } failureBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }];
}

- (void)loadMoreData
{
    _currentFollowersPage ++;
    
    //already showing activity indicator in last cell so no need for the MBProgressHUD
    [self updateInfoAndShowActivityIndicator:NO];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.searchResults = nil;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    
    NSPredicate *masterUsernamePredicate = [NSPredicate predicateWithFormat:@"following.username like %@", username];
    int fetchLimit = (_currentFollowersPage +1) *kMaxItemsPerPage;
    
    if ([searchText isEqual:@""]) {
        //seting fetch limit for pagination
        NSFetchRequest *request = [User MR_requestAllWithPredicate:masterUsernamePredicate];
        [request setFetchLimit:fetchLimit];
        //set sort descriptor
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        self.searchResults = [User MR_executeFetchRequest:request];
    } else {
        NSPredicate *usernameSearchPredicate = [NSPredicate predicateWithFormat:@"username contains[cd] %@ OR name contains[cd] %@", searchText, searchText];
        NSArray *predicatesArray = [NSArray arrayWithObjects:masterUsernamePredicate, usernameSearchPredicate, nil];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
        self.searchResults = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:predicate];
    }
    [self reloadTableView];
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

- (void)reloadTableView
{
    if ([_searchBar.text length] > 0) {
        //reload searchresultstableview tu update cell
        for (UITableView *tView in self.view.subviews) {
            if ([[tView class] isSubclassOfClass:[UITableView class]]) {
                [tView reloadData];
                break;
            }
        }
    }
    else {
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    int result = [self.searchResults count];
    
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
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.searchResults count]) {
        SDNewConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultsCell"];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDNewConversationCell" owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                    cell = (SDNewConversationCell *) currentObject;
                    break;
                }
            }
        } else {
            [cell.userImageView cancelImageRequestOperation];
        }
        
        User *user = [self.searchResults objectAtIndex:indexPath.row];
        cell.usernameTitle.text = user.name;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
        [cell.userImageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                     cropedForSize:CGSizeMake(50, 50)
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               SDNewConversationCell *myCell = (SDNewConversationCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                               myCell.userImageView.image = image;
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               //
                                           }];
        
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
        
        if (!_searchActive) {
            [self loadMoreData];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

#pragma mark - UISearchDisplayController delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchActive = YES;
    //filter users in local DB
    [self filterContentForSearchText:searchString];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    
    if ((_currentFollowersPage+1)*kMaxItemsPerPage < _totalFollowers ) { //if all users are already downloaded we do not need additional call to webservice
        
        [SDFollowingService getListOfFollowersForUserWithIdentifier:master.identifier withSearchString:searchString withCompletionBlock:^{
            _searchActive = NO;
            //in case later request will finish first, use _searchBar.text
            [self filterContentForSearchText:_searchBar.text];
        } failureBlock:^{
            _searchActive = NO;
        }];
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

#pragma mark - Seque transitions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"ConversationViewControllerId"]) {
        
        NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
        
        //Create conversation for user at indexPath
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Conversation *conversation = [Conversation MR_createInContext:context];
        User *selectedUser = [self.searchResults objectAtIndex:indexPath.row];
        [conversation addUsersObject:selectedUser];
        [context MR_save];
        
        SDConversationViewController *conversationViewController = (SDConversationViewController *)[segue destinationViewController];
        conversationViewController.conversation = conversation;
        conversationViewController.isNewConversation = YES;
    }
}

@end