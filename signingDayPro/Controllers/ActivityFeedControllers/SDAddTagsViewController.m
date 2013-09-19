//
//  SDAddTagsViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import "SDAddTagsViewController.h"
#import "SDModalNavigationController.h"
#import "SDLoginService.h"
#import "Master.h"
#import "SDChatService.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "SDAddTagsCell.h"
#import "AFNetworking.h"
#import "SDFollowingService.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+Crop.h"

@interface SDAddTagsViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *selectedTags;
@property (nonatomic, strong) UIBarButtonItem *doneButtonItem;

@property (nonatomic, assign) BOOL searchActive;

@property (nonatomic, assign) int totalFollowings;
@property (nonatomic, assign) int currentFollowingPage;

- (void)filterContentForSearchText:(NSString*)searchText;
- (void)checkDoneButton;

@end

@implementation SDAddTagsViewController

@synthesize searchResults = _searchResults;
@synthesize delegate = _delegate;
@synthesize selectedTags = _selectedTags;
@synthesize doneButtonItem = _doneButtonItem;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _currentFollowingPage = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    SDModalNavigationController *modalNavigationController = (SDModalNavigationController *)self.navigationController;
    self.delegate = (id <SDAddTagsViewControllerDelegate>)modalNavigationController.myDelegate;
    
    UIImage *image = [UIImage imageNamed:@"MenuButtonClose.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    // Search bar customization
    _searchBar.tintColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:218.0f/255.0f alpha:1.0f];
    
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
    
    image = [UIImage imageNamed:@"MenuButtonDone.png"];
    frame = CGRectMake(0, 0, image.size.width, image.size.height);
    button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = self.doneButtonItem;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.selectedTags = [[NSMutableArray alloc] init];
    for (User *tagUser in [self.delegate arrayOfAlreadySelectedTags]) {
        [self.selectedTags addObject:tagUser];
    }
    
    [self checkDoneButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateInfoAndShowActivityIndicator:YES];
}

- (void)userDidLogout
{
    self.searchResults = nil;
}

#pragma mark - filter & info update

- (void)updateInfoAndShowActivityIndicator:(BOOL)showActivityIndicator
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    if (showActivityIndicator) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.labelText = @"Updating list";
    }
    
        //get list of followings
        [SDFollowingService getListOfFollowersForUserWithIdentifier:master.identifier forPage:_currentFollowingPage withCompletionBlock:^(int totalFollowingCount) {
            //refresh the view
            _totalFollowings = totalFollowingCount;
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
            [self reloadView];
        } failureBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
        }];
}

- (void)loadMoreData
{
    _currentFollowingPage ++;
    
    //already showing activity indicator in last cell so no need for the MBProgressHUD
    [self updateInfoAndShowActivityIndicator:NO];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.searchResults = nil;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    
    NSPredicate *masterUsernamePredicate = [NSPredicate predicateWithFormat:@"followedBy.username like %@", username];
    int fetchLimit = (_currentFollowingPage +1) *kMaxItemsPerPage;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([searchText isEqual:@""]) {
        //seting fetch limit for pagination
        NSFetchRequest *request = [User MR_requestAllWithPredicate:masterUsernamePredicate inContext:context];
        [request setFetchLimit:fetchLimit];
        //set sort descriptor
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        self.searchResults = [User MR_executeFetchRequest:request inContext:context];
    } else {
        NSPredicate *usernameSearchPredicate = [NSPredicate predicateWithFormat:@"username contains[cd] %@ OR name contains[cd] %@", searchText, searchText];
        NSArray *predicatesArray = [NSArray arrayWithObjects:masterUsernamePredicate, usernameSearchPredicate, nil];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
        self.searchResults = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:predicate inContext:context];
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

- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)doneButtonPressed
{
    [self.delegate addTagsViewController:self didFinishPickingTags:self.selectedTags];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)checkDoneButton
{
    if ([self.selectedTags count] == 0 && [[self.delegate arrayOfAlreadySelectedTags] count] == 0)
        self.doneButtonItem.enabled = NO;
    else
        self.doneButtonItem.enabled = YES;
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
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.searchResults count]) {
        
        SDAddTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTagsCell"];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDAddTagsCell" owner:nil options:nil];
            for (id currentObject in topLevelObjects) {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                    cell = (SDAddTagsCell *) currentObject;
                    break;
                }
            }
            cell.backgroundColor = [UIColor clearColor];
        }
        
        User *user = [self.searchResults objectAtIndex:indexPath.row];
        
        if ([self.selectedTags containsObject:user]) 
            cell.isChecked = YES;
        else 
            cell.isChecked = NO;
        
        cell.userTitleLabel.text = user.name;
            
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
        [cell.userImageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                     cropedForSize:CGSizeMake(48, 48)
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               
                                               SDAddTagsCell *myCell = (SDAddTagsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                               myCell.userImageView.image = image;
                                               
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               //
                                           }];
        
        [self checkDoneButton];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    User *user = [self.searchResults objectAtIndex:indexPath.row];
    
    SDAddTagsCell *cell = (SDAddTagsCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isChecked) {
        cell.isChecked = NO;
        [self.selectedTags removeObject:user];
    } else {
        cell.isChecked = YES;
        [self.selectedTags addObject:user];
    }
    
    [self checkDoneButton];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchDisplayController delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchActive = YES;
    //filter users in local DB
    [self filterContentForSearchText:searchString];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    if ((_currentFollowingPage+1)*kMaxItemsPerPage < _totalFollowings ) { //if all users are already downloaded we do not need additional call to webservice
        
        [SDFollowingService getListOfFollowingsForUserWithIdentifier:master.identifier withSearchString:searchString withCompletionBlock:^{
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


@end
