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

#import "SDGoogleAnalyticsService.h"

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Player Landing screen";
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
        BOOL rowNumberVisible = (self.searchBar.text.length < 3) ? YES : NO;
        [cell setupCellWithUser:user andFilteredData:!rowNumberVisible];
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
            if (self.dataIsFiltered) {
//                if (self.searchBar.text.length >= 3) {
                    [self searchFilteredData];
//                }
//                else {
//                    [self checkServer];
//                }
            }
            else {
                [self checkServer];
                [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Show_More_PlayerLandingPage"];
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int result = 0;
    if (self.pagingEndReached) {
        result = [self.dataArray count];
    }
    else {
        result = ([self.dataArray count] == 0) ? 0 : [self.dataArray count]+1;
    }
    return result;
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
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        self.dataDownloadInProgress = NO;
        NSLog(@"Data downloading failed in :%@",[self class]);
        [self hideProgressHudInView:self.view];
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
        self.pagingEndReached = NO;
        [self checkServer];
    }
    else {
        self.dataIsFiltered = YES;
        self.dataDownloadInProgress = YES;
        
        
        NSArray *stateCodeStringsArray = self.currentFilterState.code ? [NSArray arrayWithObject:self.currentFilterState.code] : nil;
        NSArray *positionStringsArray = [self.currentFilterPositionDictionary objectForKey:@"shortName"] ? [NSArray arrayWithObject:[self.currentFilterPositionDictionary objectForKey:@"shortName"]] : nil;
        NSArray *yearStringArray = (self.searchBar.text.length < 3) ? [NSArray arrayWithObject:[self.currentFilterYearDictionary valueForKey:@"name"]] : nil;
        
        NSString *sortedBy = (searchBarText.length < 3) ? [NSString stringWithFormat:@"BaseScore desc"] :[NSString stringWithFormat:@"DisplayName asc"];
        
        [SDLandingPagesService searchForPlayersWithNameString:self.searchBar.text from:self.currentSearchUserCount to:self.currentSearchUserCount+kPageCountForLandingPages stateCodeStringsArray:stateCodeStringsArray classYearsStringsArray:yearStringArray positionStringsArray:positionStringsArray sortedBy:sortedBy successBlock:^{
            
            self.currentSearchUserCount +=kPageCountForLandingPages;
            self.dataDownloadInProgress = NO;
            [self loadFilteredData];
            [self hideProgressHudInView:self.view];
        } failureBlock:^{
            self.dataDownloadInProgress = NO;
            [self hideProgressHudInView:self.view];
        }];
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
    [request setFetchLimit:self.currentUserCount];
    
    //set sort descriptors
    NSSortDescriptor *baseScoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.baseScore" ascending:NO];
    NSSortDescriptor *starsDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.starsCount" ascending:NO];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *descriptorArray = (self.searchBar.text.length < 3) ? [NSArray arrayWithObjects:baseScoreDescriptor,starsDescriptor,nameDescriptor,nil] : [NSArray arrayWithObjects:nameDescriptor,baseScoreDescriptor,starsDescriptor,nil];
    
    [request setSortDescriptors:descriptorArray];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    //checking if end for paging is reached
    if ([self.dataArray count] < self.currentUserCount) {
        self.pagingEndReached = YES;
    }
    
    [self reloadTableView];
}

- (void)loadFilteredData
{
    if (self.currentSearchUserCount > 0) {
        
        //Form and compound predicates
        NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
        
        NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypePlayer];
        NSPredicate *userYearPredicate = (self.searchBar.text.length >= 3) ? nil : [NSPredicate predicateWithFormat:@"thePlayer.userClass == %@",[self.currentFilterYearDictionary valueForKey:@"name"]];
        NSPredicate *userStatePredicate = self.currentFilterState ? [NSPredicate predicateWithFormat:@"state.code == %@",self.currentFilterState.code] : nil;
        NSPredicate *userPositionPredicate = self.currentFilterPositionDictionary ? [NSPredicate predicateWithFormat:@"thePlayer.position == %@",[self.currentFilterPositionDictionary valueForKey:@"shortName"]] : nil;
        NSPredicate *nameSearchPredicate = (self.searchBar.text.length > 0) ? [NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchBar.text] : nil;
        
        [predicateArray addObject:userTypePredicate];
        if (userYearPredicate)
            [predicateArray addObject:userYearPredicate];
        if (nameSearchPredicate)
            [predicateArray addObject:nameSearchPredicate];
        if (userStatePredicate)
            [predicateArray addObject:userStatePredicate];
        if (userPositionPredicate)
            [predicateArray addObject:userPositionPredicate];
        
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSFetchRequest *request = [User MR_requestAllWithPredicate:compoundPredicate inContext:context];
        
        [request setFetchLimit:self.currentSearchUserCount];
        
        NSSortDescriptor *baseScoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.baseScore" ascending:NO];
        NSSortDescriptor *starsDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.starsCount" ascending:NO];
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSArray *descriptorArray = (self.searchBar.text.length < 3)
        ? [NSArray arrayWithObjects:baseScoreDescriptor,starsDescriptor,nameDescriptor,nil]
        : [NSArray arrayWithObjects:nameDescriptor,baseScoreDescriptor,starsDescriptor,nil];
        
        [request setSortDescriptors:descriptorArray];
        self.dataArray = [User MR_executeFetchRequest:request inContext:context];
        
        if ([self.dataArray count] < self.currentSearchUserCount) {
            self.pagingEndReached = YES;
        }
    }
    
    [self reloadTableView];
}

#pragma mark - Search bar search clicked

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self removeKeyboard];
    self.currentSearchUserCount = 0;
    self.currentUserCount = 0;
    self.pagingEndReached = NO;
    [self showProgressHudInView:self.view withText:@"Loading"];
    [self searchFilteredData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.dataIsFiltered = NO;
    searchBar.text = @"";
    self.currentSearchUserCount = 0;
    self.currentUserCount = kPageCountForLandingPages;
    self.pagingEndReached = NO;
    [self loadData];
}

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
        self.currentSearchUserCount = 0;
        self.pagingEndReached = NO;
        [self searchFilteredData];
    }
    else {
        self.dataArray = nil;
        [self reloadTableView];
    }
    return YES;
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
    self.currentSearchUserCount = 0;
    self.pagingEndReached = NO;
    [self showProgressHudInView:self.view withText:@"Loading"];
    [self searchFilteredData];
    
    [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Search_Selected_PlayerLandingPage"];
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
