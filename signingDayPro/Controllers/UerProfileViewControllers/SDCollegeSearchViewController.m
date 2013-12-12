//
//  SDCollegeSearchViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCollegeSearchViewController.h"
#import "SDLandingPageSearchBar.h"
#import "User.h"
#import "SDProfileService.h"
#import "SDLandingPagesService.h"
#import "SDNewConversationCell.h"
#import "UIView+NibLoading.h"
#import "SDCacheService.h"
#import <AFNetworking.h>

@interface SDCollegeSearchViewController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, weak) SDLandingPageSearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *customSearchDisplayController;
@property (nonatomic, weak) UIView *searchBarBackground;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) BOOL dataIsFiltered;
@property (nonatomic, assign) BOOL dataDownloadInProgress;

@end

@implementation SDCollegeSearchViewController

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
    // Do any additional setup after loading the view from its nib.
    self.navigationTitle = @"Add team";
    
    [self.refreshControl removeFromSuperview];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.clipsToBounds = YES;
    
    [self addSearchBar];
//    [self loadData];
    [self showProgressHudInView:self.view withText:@"Loading"];
    [self checkServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"self.searchBar.frame.size.height = %f",self.searchBar.frame.size.height);
    NSLog(@"self.searchBar.frame.origin.y = %f",self.searchBar.frame.origin.y);
    NSLog(@"self.view.frame.size.height = %f",self.view.frame.size.height);
#warning temporary fix, for build!!!
    if (self.view.frame.size.height < 500) {
        self.tableView.frame = CGRectMake(0, 108, self.view.frame.size.width, self.view.frame.size.height - 108);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
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
    NSString *identifier = @"SearchResultsCell";
    SDNewConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDNewConversationCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    User *teamUser = [self.dataArray objectAtIndex:indexPath.row];
    cell.usernameTitle.text = teamUser.name;
    
    [cell.userImageView cancelImageRequestOperation];
    cell.userImageView.image = nil;
    [cell.userImageView setImageWithURL:[NSURL URLWithString:teamUser.avatarUrl]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.searchBar isFirstResponder]) {
        [self removeKeyboard];
    }
    
    [self.delegate collegeSearchViewController:self didSelectCollegeUser:[self.dataArray objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder]) {
        [self removeKeyboard];
        if (self.searchBar.text.length < 1) {
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

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (self.searchBar.text.length < 1) {
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
    if ([self.searchBar isFirstResponder])
        [self.searchBar resignFirstResponder];
    
    if ([self.customSearchDisplayController.searchBar isFirstResponder])
        [self.customSearchDisplayController.searchBar resignFirstResponder];
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


#pragma mark - Data downloading

- (void)checkServer
{
//    NSString *searchString = (self.searchBar.text.length > 0) ? self.searchBar.text : @"";
    
    BOOL updateTeams = [SDCacheService shouldTeamsBeUpdated];
    
    if (!updateTeams) {
        [self loadData];
    }
    else {
        
        self.dataDownloadInProgress = YES;
        [SDLandingPagesService getTeamsWithSearchString:@"" completionBlock:^{
            self.dataDownloadInProgress = NO;
            [self loadData];
        } failureBlock:^{
            self.dataDownloadInProgress = NO;
            NSLog(@"Data downloading failed in :%@",[self class]);
        }];
    }
}

- (void)searchFilteredData
{
    if (self.searchBar.text.length < 1) {
        [self loadData];
    }
    else {
        [self loadFilteredData];
    }
}


#pragma mark - Data Fetching

- (void)loadData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeTeam];
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name!=nil AND name!=''"];
    NSPredicate *compoundedPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, namePredicate]];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
//    NSFetchRequest *request = [User MR_requestAllWithPredicate:compoundedPredicate inContext:context];
//    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//    [request setSortDescriptors:[NSArray arrayWithObjects:nameDescriptor,nil]];
//    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    self.dataArray = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:compoundedPredicate inContext:context];
    
    [self hideProgressHudInView:self.view];
    [self reloadTableView];
}

- (void)loadFilteredData
{
    NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeTeam];
    NSPredicate *nameSearchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchBar.text];
    
    NSPredicate *compoundPredicate = (self.searchBar.text.length > 0) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate,nameSearchPredicate]] : [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate]];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataArray = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:compoundPredicate inContext:context];
    
    [self reloadTableView];
    [self hideProgressHudInView:self.view];
}

#pragma mark - Searchresults controller delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //change text for default "No results", to my own
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        for (UIView *v in controller.searchResultsTableView.subviews) {
            if ([v isKindOfClass:[UILabel self]]) {
                if (searchString.length < 1) {
                    ((UILabel *)v).text = @"Enter minimum 1 symbols";
                }
                else {
                    ((UILabel *)v).text = @"No results";
                }
                break;
            }
        }
    });
    
    if (searchString.length > 0) {
//        [self loadFilteredData];
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


- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void) keyboardWillHide {
    
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
}


@end
