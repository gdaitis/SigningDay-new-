//
//  SDBaseUserSearchViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/7/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDCommonUserSearchViewController.h"
#import "SDCantFindYourselfView.h"

#define kHideKeyboardButtonTag 999

@interface SDCommonUserSearchViewController () <SDCantFindYourselfViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet SDCantFindYourselfView *cantFindYourselfView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

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
    self.cantFindYourselfView.delegate = self;
    [self.refreshControl removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSearchBar
{
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc]
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
    UIButton *hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyboardButton.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kKeyboardHeightPortrait);
    
    hideKeyboardButton.tag = kHideKeyboardButtonTag;
    [hideKeyboardButton addTarget:self action:@selector(removeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hideKeyboardButton];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self loadDataWithSearchString:searchBar.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self removeKeyboard];
    return YES;
}

- (void)removeKeyboard
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [(UIButton *)[self.view viewWithTag:kHideKeyboardButtonTag] removeFromSuperview];
    }
    if ([self.customSearchDisplayController.searchBar isFirstResponder]) {
        [self.customSearchDisplayController.searchBar resignFirstResponder];
        [(UIButton *)[self.view viewWithTag:kHideKeyboardButtonTag] removeFromSuperview];
    }
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
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.searchBar isFirstResponder])
        [self removeKeyboard];
    
    //show claim controller
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder]) {
        [self removeKeyboard];
        [self loadDataWithSearchString:self.searchBar.text];
    }
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
        [self loadLocalDbDataWithString:searchString];
        [self checkServer];
        [self loadLocalDbDataWithString:searchString];
    }
    else if (searchString.length <= 2 && searchString.length > 0) {
        self.dataArray = nil;
        [self reloadTableView];
    }
    else {
        self.dataArray = nil;
        [self reloadTableView];
#warning show label with text "Enter minimum 3 symbols" ?
    }
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self reloadTableView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}


- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void) keyboardWillHide
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark - Cant Find Yourself View Delegate

- (void)registerButtonPressedInCantFindYourselfView:(SDCantFindYourselfView *)cantFindYourselfView
{
    
}

@end
