//
//  SDPlayerLandingPageViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDPlayerLandingPageViewController.h"

#import "SDLandingPagePlayerCell.h"
#import "UIView+NibLoading.h"
#import "UIButton+AddTitle.h"
#import "State.h"
#import "SDPlayersSearchHeader.h"
#import "AFNetworking.h"

@interface SDPlayerLandingPageViewController () <UITableViewDataSource, UITableViewDelegate,SDPlayersSearchHeaderDelegate>

@property (nonatomic, strong) SDPlayersSearchHeader *playerSearchView;

//filter props
@property (nonatomic, strong) State *currentFilterState;
@property (nonatomic, strong) NSDictionary *currentFilterPositionDictionary;
@property (nonatomic, strong) NSDictionary *currentFilterYearDictionary;

@property (nonatomic, assign) int currentSearchUserCount;

@end

@implementation SDPlayerLandingPageViewController

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
    //default value for the filter is 2014, assigning this to filter property
    NSString *path = [[NSBundle mainBundle] pathForResource:@"YearsList" ofType:@"plist"];
    NSArray *yearDictionaryArray = [[NSArray alloc] initWithContentsOfFile:path];
    self.currentFilterYearDictionary = [yearDictionaryArray objectAtIndex:1];
    
    self.currentSearchUserCount = 0;
    
    [super viewDidLoad];
    
    [self loadData];
    [self showProgressHudInView:self.view withText:@"Loading"];
    [self checkServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateFilterButtonNames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataArray count] || self.pagingEndReached) {
        NSString *identifier = @"SDLandingPagePlayerCellIdentifier";
        SDLandingPagePlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = (id)[SDLandingPagePlayerCell loadInstanceFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        User *user = [self.dataArray objectAtIndex:indexPath.row];
        
        cell.playerPositionLabel.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Filter View handling

- (void)hideFilterView
{
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.playerSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y - frame.size.height;
        self.playerSearchView.frame = frame;
        
    } completion:^(__unused BOOL finished) {
        [self.playerSearchView removeFromSuperview];
        self.playerSearchView = nil;
    }];
    
    //we should tell that filter view was hidden by not using the filter button, so navigation controller could know the state.
    [((SDNavigationController *)self.navigationController) filterViewBecameHidden];
}

- (int)heightForFilterHidingButton
{
    if (self.playerSearchView) {
        return 130;
    }
    else
        return 0;
}

- (void)showFilterView
{
    if (!self.playerSearchView) {
        SDPlayersSearchHeader *playerHeaderView = [[SDPlayersSearchHeader alloc] init];
        playerHeaderView.delegate = self;
        self.playerSearchView = playerHeaderView;
    }
    
    //hide SDPlayerSearchHeader under toolbar
    CGRect frame = self.playerSearchView.frame;
    frame.origin.y = self.searchBarBackground.frame.origin.y - frame.size.height;
    self.playerSearchView.frame = frame;
    [self.view addSubview:self.playerSearchView];
    
    [self updateFilterButtonNames];
    
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.playerSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y;
        self.playerSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
    }];
}

- (void)updateFilterButtonNames
{
    if (self.playerSearchView) {
        //Position Button
        if (self.currentFilterPositionDictionary)
            [self.playerSearchView.positionsButton setCustomTitle:[self.currentFilterPositionDictionary valueForKey:@"name"]];
        else
            [self.playerSearchView.positionsButton setCustomTitle:kDefaultPositionFilterName];
        
        //Year button
        if (self.currentFilterYearDictionary)
            [self.playerSearchView.yearsButton setCustomTitle:[self.currentFilterYearDictionary valueForKey:@"name"]];
        else
            [self.playerSearchView.yearsButton setCustomTitle:kDefaultYearFilterName];
        
        //State button
        if (self.currentFilterState)
            [self.playerSearchView.statesButton setCustomTitle:self.currentFilterState.name];
        else
            [self.playerSearchView.statesButton setCustomTitle:kDefaultStateFilterName];
    }
}

#pragma mark - Search and Data loading

- (void)checkServer
{
    self.dataDownloadInProgress = YES;
    
    [SDLandingPagesService getPlayersOrderedByDescendingBaseScoreFrom:self.currentUserCount to:self.currentUserCount + kPageCountForLandingPages forClass:[self.currentFilterYearDictionary objectForKey:@"name"] successBlock:^{
        self.currentUserCount += kPageCountForLandingPages;
        self.dataDownloadInProgress = NO;
        [self loadData];
    } failureBlock:^{
        self.dataDownloadInProgress = NO;
        NSLog(@"Data downloading failed in :%@",[self class]);
    }];
}

- (void)searchFilteredData
{
    [self hideFilterView];
    //need to set dataIsFilteredFlag to know if we should hide position number on players photo in player cell.
    NSString *searchBarText = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (searchBarText.length < 3 && self.currentFilterState == nil && self.currentFilterPositionDictionary == nil) {
        self.dataIsFiltered = NO;
        self.currentUserCount = 0;
        [self checkServer];
    }
    else {
        self.dataIsFiltered = YES;
    
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    NSArray *stateCodeStringsArray = self.currentFilterState.code ? [NSArray arrayWithObject:self.currentFilterState.code] : nil;
    NSArray *classYearsStringsArray = [self.currentFilterYearDictionary objectForKey:@"name"] ? [NSArray arrayWithObject:[self.currentFilterYearDictionary objectForKey:@"name"]] : nil;
    NSArray *positionStringsArray = [self.currentFilterPositionDictionary objectForKey:@"shortName"] ? [NSArray arrayWithObject:[self.currentFilterPositionDictionary objectForKey:@"shortName"]] : nil;
    
#warning finish me
    [SDLandingPagesService searchForPlayersWithNameString:self.searchBar.text from:self.currentSearchUserCount to:self.currentSearchUserCount+kPageCountForLandingPages stateCodeStringsArray:stateCodeStringsArray classYearsStringsArray:classYearsStringsArray positionStringsArray:positionStringsArray successBlock:^{
        [self loadFilteredData];
    } failureBlock:^{
        
    }];
    
//    [SDLandingPagesService searchForPlayersWithNameString:self.searchBar.text stateCodeStringsArray:stateCodeStringsArray
//                                   classYearsStringsArray:classYearsStringsArray
//                                     positionStringsArray:positionStringsArray
//                                             successBlock:^{
//                                                 [self loadFilteredData];
//                                             } failureBlock:^{
//                                                 NSLog(@"failed");
//                                             }];
    }
}

#pragma mark - Data fetching

- (void)loadData
{
    NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypePlayer];
    NSPredicate *userYearPredicate = [NSPredicate predicateWithFormat:@"thePlayer.userClass == %@",[self.currentFilterYearDictionary valueForKey:@"name"]];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate, userYearPredicate]];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
    NSFetchRequest *request = [User MR_requestAllWithPredicate:compoundPredicate inContext:context];
    NSLog(@"self.currentUserCount = %d",self.currentUserCount);
    [request setFetchLimit:self.currentUserCount];
    //set sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.baseScore" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    //checking if end for paging is reached
    if ([self.dataArray count] < self.currentUserCount) {
        self.pagingEndReached = YES;
    }
    [self hideProgressHudInView:self.view];
    [self reloadTableView];
}

- (void)loadFilteredData
{
    //Form and compound predicates
    NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
    
    NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypePlayer];
    NSPredicate *userYearPredicate = [NSPredicate predicateWithFormat:@"thePlayer.userClass == %@",[self.currentFilterYearDictionary valueForKey:@"name"]];
    NSPredicate *userStatePredicate = self.currentFilterState ? [NSPredicate predicateWithFormat:@"state.code == %@",self.currentFilterState.code] : nil;
    NSPredicate *userPositionPredicate = self.currentFilterPositionDictionary ? [NSPredicate predicateWithFormat:@"thePlayer.position == %@",[self.currentFilterPositionDictionary valueForKey:@"shortName"]] : nil;
    NSPredicate *nameSearchPredicate = (self.searchBar.text.length > 0) ? [NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchBar.text] : nil;
    
    
    [predicateArray addObject:userTypePredicate];
    [predicateArray addObject:userYearPredicate];
    if (nameSearchPredicate)
        [predicateArray addObject:nameSearchPredicate];
    if (userStatePredicate)
        [predicateArray addObject:userStatePredicate];
    if (userPositionPredicate)
        [predicateArray addObject:userPositionPredicate];
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataArray = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:compoundPredicate inContext:context];
    
    [self reloadTableView];
    [self hideProgressHudInView:self.view];
}

#pragma mark - Search bar search clicked

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self removeKeyboard];
    [self searchFilteredData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.dataIsFiltered = NO;
    [self loadData];
}

#pragma mark - SDPlayersSearchHeader Delegate

- (void)playersSearchHeaderPressedStatesButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self presentFilterListViewWithType:LIST_TYPE_STATES andSelectedValue:self.currentFilterState];
}

- (void)playersSearchHeaderPressedYearsButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self presentFilterListViewWithType:LIST_TYPE_YEARS andSelectedValue:self.currentFilterYearDictionary];
}

- (void)playersSearchHeaderPressedPositionsButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self presentFilterListViewWithType:LIST_TYPE_POSITIONS andSelectedValue:self.currentFilterPositionDictionary];
}

- (void)playersSearchHeaderPressedSearchButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self searchFilteredData];
}

#pragma mark - Filter list delegates

- (void)stateChosen:(State *)state inFilterListController:(SDFilterListViewController *)filterListViewController
{
    self.currentFilterState = state;
}

- (void)yearsChosen:(NSDictionary *)years inFilterListController:(SDFilterListViewController *)filterListViewController
{
    self.currentFilterYearDictionary = years;
}

- (void)positionChosen:(NSDictionary *)position inFilterListController:(SDFilterListViewController *)filterListViewController
{
    self.currentFilterPositionDictionary = position;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SDLandingPagePlayerCell" bundle:nil] forCellReuseIdentifier:@"SDLandingPagePlayerCellIdentifier"];
}

@end
