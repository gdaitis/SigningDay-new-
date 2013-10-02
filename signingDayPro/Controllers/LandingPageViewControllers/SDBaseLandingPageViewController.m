//
//  SDBaseLandingPageViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseLandingPageViewController.h"

#define kHideKeyboardTag 999

@interface SDBaseLandingPageViewController () <UISearchBarDelegate>


@end

@implementation SDBaseLandingPageViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addSearchBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFilter:) name:kFilterButtonPressedNotification object:nil];
    [((SDNavigationController *)self.navigationController) addFilterButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFilterButtonPressedNotification object:nil];
    [((SDNavigationController *)self.navigationController) removeFilterButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboards

- (void)hideAllHeyboards
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int result = 0;
    if (self.pagingEndReached || self.searchBar.text.length > 0 || self.dataIsFiltered) {
        result = [self.dataArray count];
    }
    else {
        result = ([self.dataArray count] == 0) ? 0 : [self.dataArray count]+1;
    }
    return result;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchBar isFirstResponder]) {
        [self removeKeyboard];
        if (self.searchBar.text.length < 1) {
            self.currentUserCount = 0;
            self.dataIsFiltered = NO;
            [self loadData];
        }
    }
    else {
        UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                            bundle:nil];
        SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        userProfileViewController.currentUser = [self.dataArray objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder]) {
        [self removeKeyboard];
        if (self.searchBar.text.length < 1) {
            self.currentUserCount = 0;
            self.dataIsFiltered = NO;
            [self loadData];
        }
    }
}

- (void)addSearchBar
{
    if (!self.searchBarBackground) {
        
        float searchBarHeight = 44.0f;
        
        float y = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 20.0 : 0;
        
        UIView *searchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, y+searchBarHeight, self.view.frame.size.width, searchBarHeight)];
        searchBackgroundView.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
        
        SDLandingPageSearchBar *searchB = [[SDLandingPageSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, searchBarHeight)];
        self.searchBar = searchB;
        self.searchBar.delegate = self;
        
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc]
                                                              initWithSearchBar:_searchBar contentsController:self];
        
        self.customSearchDisplayController = searchDisplayController;
        
        _customSearchDisplayController.delegate = self;
        _customSearchDisplayController.searchResultsDataSource = self;
        _customSearchDisplayController.searchResultsDelegate = self;
        
        [searchBackgroundView addSubview:self.searchBar];
        self.searchBarBackground = searchBackgroundView;
        [self.view addSubview:self.searchBarBackground];
        
        CGRect frame = self.tableView.frame;
        frame.origin.y = searchBackgroundView.frame.size.height + searchBackgroundView.frame.origin.y;
        frame.size.height = self.view.frame.size.height - searchBackgroundView.frame.size.height - searchBackgroundView.frame.origin.y;
        self.tableView.frame = frame;
    }
}

#pragma mark - UISearchBar delegate

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    [self searchFilteredData];
//}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UIButton *hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyboardButton.frame = CGRectMake(0, 100, self.view.bounds.size.width, [self heightForFilterHidingButton]);
    
    hideKeyboardButton.tag = kHideKeyboardTag;
    [hideKeyboardButton addTarget:self action:@selector(removeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hideKeyboardButton];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (self.searchBar.text.length < 1) {
        self.currentUserCount = 0;
        self.dataIsFiltered = NO;
        [self loadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self removeKeyboard];
    return YES;
}

- (void)removeKeyboard
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [(UIButton *)[self.view viewWithTag:kHideKeyboardTag] removeFromSuperview];
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

#pragma mark - FilterButtonActions

- (void)showFilter:(NSNotification *)notification
{
    [self removeKeyboard];
    
    if ([self.searchBar isFirstResponder]) {
        UIButton *keyboardHidingButton = (UIButton *)[self.view viewWithTag:kHideKeyboardTag];
        if (keyboardHidingButton) {
            [self.view bringSubviewToFront:keyboardHidingButton];
        }
    }
    if ([[[notification userInfo] objectForKey:@"hideFilterView"] boolValue]) {
        [self hideFilterView];
    }
    else {
        [self showFilterView];
    }
}

- (int)heightForFilterHidingButton
{
    //returning height in extended controllers
    return 0;
}



#pragma mark - Filter List Presentation

- (void)presentFilterListViewWithType:(FilterListType)listType andSelectedValue:(id)value
{
    //    [self hideFilterView];
    UIStoryboard *landingPageViewStoryboard = [UIStoryboard storyboardWithName:@"LandingPageStoryBoard"
                                                                        bundle:nil];
    SDFilterListViewController *filterListViewController = [landingPageViewStoryboard instantiateViewControllerWithIdentifier:@"SDFilterListViewController"];
    filterListViewController.filterListType = listType;
    filterListViewController.delegate = self;
    filterListViewController.selectedItem = value;
    
    [self.navigationController pushViewController:filterListViewController animated:YES];
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
    
    if (searchString.length > 2) {
        [self loadFilteredData];
        [self searchFilteredData];
    }
    else {
        self.dataArray = nil;
        [self reloadTableView];
    }
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self reloadTableView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

#pragma mark - Functions which extended classes should overide

- (void)hideFilterView
{
    
}

- (void)showFilterView
{
    
}

- (void)searchFilteredData
{
    
}

- (void)loadData
{
    
}

- (void)loadFilteredData
{
    
}

@end
