//
//  SDHighSchoolLandingPageViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/5/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDHighSchoolLandingPageViewController.h"

#import "SDLandingPageHighSchoolCell.h"
#import "UIView+NibLoading.h"
#import "SDHighSchoolsSearchHeader.h"
#import "UIButton+AddTitle.h"
#import "State.h"

NSString * const kSDDefaultClass = @"2014";

@interface SDHighSchoolLandingPageViewController () <UITableViewDataSource, UITableViewDelegate,SDHighSchoolSearchHeaderDelegate,SDFilterListDelegate>

@property (nonatomic, strong) SDHighSchoolsSearchHeader *highSchoolSearchView;
@property (nonatomic, strong) State *currentFilterState;
@property (nonatomic, strong) NSDictionary *currentFilterYearDictionary;

@end

@implementation SDHighSchoolLandingPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateFilterButtonNames];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadData];
    [self showProgressHudInView:self.view withText:@"Loading"];
    [self checkServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataArray count] || self.pagingEndReached) {
        NSString *identifier = @"SDLandingPageHighSchoolCellIdentifier";
        SDLandingPageHighSchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = (id)[SDLandingPageHighSchoolCell loadInstanceFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        User *user = [self.dataArray objectAtIndex:indexPath.row];
        cell.userPositionLabel.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
        
        // Configure the cell...
        [cell setupCellWithUser:user andFilteredData:self.dataIsFiltered];
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIActivityIndicatorViewStyle activityViewStyle = UIActivityIndicatorViewStyleGray;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        if (!self.dataDownloadInProgress) {
            //data downloading not in progress, we can start downloading further pages
            [self checkServer];
        }
        return cell;
    }
}

#pragma mark - Filter button actions

- (void)hideFilterView
{
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.highSchoolSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y - frame.size.height;
        self.highSchoolSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
        [self.highSchoolSearchView removeFromSuperview];
        self.highSchoolSearchView = nil;
    }];
    
    //we should tell that filter view was hidden by not using the filter button, so navigation controller could know the state.
    [((SDNavigationController *)self.navigationController)  filterViewBecameHidden];
}

- (int)heightForFilterHidingButton
{
    if (self.highSchoolSearchView) {
        return 50;
    }
    else
        return 0;
}

- (void)showFilterView
{
    
    if (!self.highSchoolSearchView) {
        
        SDHighSchoolsSearchHeader *highSchoolSearchView = [[SDHighSchoolsSearchHeader alloc] init];
        highSchoolSearchView.delegate = self;
        self.highSchoolSearchView = highSchoolSearchView;
    }
    
    //hide SDHighSchoolHeaderView under toolbar
    CGRect frame = self.highSchoolSearchView.frame;
    frame.origin.y = self.searchBarBackground.frame.origin.y - frame.size.height;
    self.highSchoolSearchView.frame = frame;
    
    [self.view addSubview:self.highSchoolSearchView];
    
    [self updateFilterButtonNames];
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.highSchoolSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y;
        self.highSchoolSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
    }];
}

- (void)updateFilterButtonNames
{
    if (self.highSchoolSearchView) {
        
        //State button
        if (self.currentFilterState)
            [self.highSchoolSearchView.statesButton setCustomTitle:self.currentFilterState.name];
        else
            [self.highSchoolSearchView.statesButton setCustomTitle:kDefaultStateFilterName];
    }
}

#pragma mark - Data Fetching

- (void)loadData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeHighSchool];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
    NSFetchRequest *request = [User MR_requestAllWithPredicate:predicate inContext:context];
    [request setFetchLimit:self.currentUserCount];
    //set sort descriptor
    NSSortDescriptor *prospectsDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theHighSchool.totalProspects" ascending:NO];
    NSSortDescriptor *baseAverageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theHighSchool.baseAverage" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObjects:prospectsDescriptor,baseAverageDescriptor,nil]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    if ([self.dataArray count] < self.currentUserCount) {
        self.pagingEndReached = YES;
    }
    
    [self reloadTableView];
}

- (void)loadFilteredData
{
    NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
                                      
    NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeHighSchool];
    NSPredicate *nameSearchPredicate = (self.searchBar.text.length > 0) ? [NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchBar.text] : nil;
    NSPredicate *userStatePredicate = self.currentFilterState ? [NSPredicate predicateWithFormat:@"theHighSchool.stateCode == %@",self.currentFilterState.code] : nil;

    [predicateArray addObject:userTypePredicate];
    if (nameSearchPredicate)
        [predicateArray addObject:nameSearchPredicate];
    if (userStatePredicate)
        [predicateArray addObject:userStatePredicate];
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataArray = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:compoundPredicate inContext:context];
    
    [self reloadTableView];
    [self hideProgressHudInView:self.view];
}

#pragma mark - Data downlaoding

- (void)checkServer
{
    self.dataDownloadInProgress = YES;
    [SDLandingPagesService getAllHighSchoolsForAllStatesForYearString:kSDDefaultClass pageNumber:(self.currentUserCount/kPageCountForLandingPages) pageSize:kPageCountForLandingPages successBlock:^{
        self.currentUserCount +=kPageCountForLandingPages;
        self.dataDownloadInProgress = NO;
        [self loadData];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
        self.dataDownloadInProgress = NO;
    }];
    
//    [SDLandingPagesService getAllHighSchoolsForAllStatesForYearString:kSDDefaultClass successBlock:^{
//        self.currentUserCount +=kPageCountForLandingPages;
//        self.dataDownloadInProgress = NO;
//        [self loadData];
//        [self hideProgressHudInView:self.view];
//    } failureBlock:^{
//        [self hideProgressHudInView:self.view];
//        self.dataDownloadInProgress = NO;
//    }];
}

- (void)searchFilteredData
{
    [self hideFilterView];
    //need to set dataIsFilteredFlag to know if we should hide position number on players photo in player cell.
    self.dataIsFiltered = YES;
    [self showProgressHudInView:self.view withText:@"Loading"];
    NSArray *stateCodeStringsArray = self.currentFilterState.code ? [NSArray arrayWithObject:self.currentFilterState.code] : nil;
    
    [SDLandingPagesService searchForHighSchoolsWithNameString:self.searchBar.text yearString:kSDDefaultClass stateCodeStringsArray:stateCodeStringsArray successBlock:^{
        [self loadFilteredData];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        [self hideProgressHudInView:self.view];
        NSLog(@"Search failed in Highschool landing page");
    }];
}

#pragma mark - Search bar search clicked

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self removeKeyboard];
    self.currentUserCount = 0;
    self.pagingEndReached = NO;
    [self searchFilteredData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.currentUserCount = 0;
    self.dataIsFiltered = NO;
    self.pagingEndReached = NO;
    [self loadData];
}

#pragma mark - SDPlayersSearchHeader Delegate


- (void)highSchoolSearchHeaderPressedStatesButton:(SDHighSchoolsSearchHeader *)highSchoolSearchHeader
{
    [self presentFilterListViewWithType:LIST_TYPE_STATES andSelectedValue:self.currentFilterState];
}

- (void)highSchoolSearchHeaderPressedSearchButton:(SDHighSchoolsSearchHeader *)highSchoolSearchHeader
{
    self.currentUserCount = 0;
    self.pagingEndReached = NO;
    [self searchFilteredData];
}

#pragma mark - Filter list delegates

- (void)stateChosen:(State *)state inFilterListController:(SDFilterListViewController *)filterListViewController
{
    self.currentFilterState = state;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SDLandingPageHighSchoolCell" bundle:nil] forCellReuseIdentifier:@"SDLandingPageHighSchoolCellIdentifier"];
}

@end