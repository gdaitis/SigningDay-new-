//
//  SDBaseUserSearchViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/7/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDCommonUserSearchViewController.h"
#import "SDUserSearchClaimAccountCell.h"
#import "SDSearchDisplayController.h"
#import "UIView+NibLoading.h"
#import "User.h"
#import "SDClaimRegistrationViewController.h"

@interface SDCommonUserSearchViewController () <UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) SDSearchDisplayController *customSearchDisplayController;
@property (nonatomic, strong) UILabel *infoLabel;  //displays info text "Enter minimu 3 symbols for search"

@end

@implementation SDCommonUserSearchViewController

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
    [self.refreshControl removeFromSuperview];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Enter minimum 3 symbols";
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor lightGrayColor];
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = self.tableView.bounds.size.width/2 - frame.size.width/2;
    frame.origin.y = 98; //hardcoded to overlap native title, and not to glitch on the screen
    label.frame = frame;
    
    self.infoLabel = label;
    [self.tableView addSubview:self.infoLabel];
    [self setupSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //this is done, because at the moment there is no way of representing static searchbar for uisearchdisplaycontroller
    NSString *beforeHidingText = self.searchBar.text;
    [self.customSearchDisplayController setActive:NO animated:NO];
    if (beforeHidingText && beforeHidingText.length > 0)
        self.searchBar.text = beforeHidingText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSearchBar
{
    SDSearchDisplayController *searchDisplayController = [[SDSearchDisplayController alloc]
                                                          initWithSearchBar:self.searchBar contentsController:self];
    
    self.customSearchDisplayController = searchDisplayController;
    
    self.customSearchDisplayController.delegate = self;
    self.customSearchDisplayController.searchResultsDataSource = self;
    self.customSearchDisplayController.searchResultsDelegate = self;
    self.searchBar.delegate = self;
}

#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
//    [self loadDataWithSearchString:searchBar.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self removeKeyboard];
    return YES;
}

- (void)removeKeyboard
{
    if ([self.searchBar isFirstResponder])
        [self.searchBar resignFirstResponder];
    if ([self.customSearchDisplayController.searchBar isFirstResponder])
        [self.customSearchDisplayController.searchBar resignFirstResponder];
}

- (void)reloadTableView
{
    if ([self.searchBar.text length] > 0) {
        //reload searchresultstableview to update cell
        [_customSearchDisplayController.searchResultsTableView reloadData];
    }
    else {
        [self.tableView reloadData];
    }
}

#pragma mark - Keyboards

- (void)hideAllHeyboards
{
    [self removeKeyboard];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"SDUserSearchClaimAccountCellID";
    SDUserSearchClaimAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = (id)[SDUserSearchClaimAccountCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.claimButton addTarget:self action:@selector(claimButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.claimButton.tag = indexPath.row;
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    [cell setupCellWithUser:user];
    cell.locationLabel.text = [self addressTitleForUser:user];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.searchBar isFirstResponder])
        [self removeKeyboard];
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    [self claimAccount:user];
}

- (void)claimButtonPressed:(id)sender
{
    User *user = [self.dataArray objectAtIndex:((UIButton *)sender).tag];
    [self claimAccount:user];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder])
        [self removeKeyboard];
}

#pragma mark - Searchresults controller delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //change text for default "No results", to my own
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        for (UIView *v in controller.searchResultsTableView.subviews) {
            if ([v isKindOfClass:[UILabel self]]) {
                if (searchString.length < 3) {
                    ((UILabel *)v).text = @"Enter minimum 3 symbols";
                }
                else {
                    ((UILabel *)v).text = @"No results";
                }
                break;
            }
        }
    });
    [self loadDataWithSearchString:searchString];
    
    return YES;
}

- (void)loadDataWithSearchString:(NSString *)searchString
{
    if (searchString.length > 2) {
        [self hideInfoText];
        [self loadLocalDbDataWithString:searchString];
        if ([self respondsToSelector:@selector(checkServerForUsersWithNameSubstring:)])
            [self checkServerForUsersWithNameSubstring:searchString];
    }
    else if (searchString.length <= 2 && searchString.length > 0) {
        [self hideInfoText];
        self.dataArray = nil;
        [self reloadTableView];
    }
    else {
        self.dataArray = nil;
        [self reloadTableView];
        [self displayInfoText];
    }
}

- (void)displayInfoText
{
    self.infoLabel.hidden = NO;
}

- (void)hideInfoText
{
    self.infoLabel.hidden = YES;
}

- (void)dataLoadedForSearchString:(NSString *)searchString
{
    [self loadLocalDbDataWithString:searchString];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self reloadTableView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}


- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWillHide
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self loadDataWithSearchString:nil];
}

#pragma mark - Data loading

- (void)loadLocalDbDataWithString:(NSString *)searchString
{
    //Form and compound predicates
    
    NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",self.userType];
    NSPredicate *nameSearchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate,nameSearchPredicate]];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *request = [User MR_requestAllWithPredicate:compoundPredicate inContext:context];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *descriptorArray = [NSArray arrayWithObject:nameDescriptor];
    [request setSortDescriptors:descriptorArray];
    
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    [self reloadTableView];
}

#pragma mark - Cant Find Yourself View Delegate

- (void)claimAccount:(User *)user
{
    [self removeKeyboard];
    SDClaimRegistrationViewController *crvc = [[SDClaimRegistrationViewController alloc] init];
    crvc.user = user;
    [self.navigationController pushViewController:crvc
                                         animated:YES];
}

@end
