//
//  SDCollegeLandingPageViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/5/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCollegeLandingPageViewController.h"

#import "SDLandingPageCollegeCell.h"
#import "UIView+NibLoading.h"
#import "SDTeamsSearchHeader.h"
#import "UIButton+AddTitle.h"
#import "Conference.h"
#import "SDGoogleAnalyticsService.h"

@interface SDCollegeLandingPageViewController () <UITableViewDataSource, UITableViewDelegate,SDTeamsSearchHeaderDelegate>

@property (nonatomic, strong) SDTeamsSearchHeader *teamSearchView;

@property (nonatomic, strong) Conference *currentFilterConference;
@property (nonatomic, strong) NSDictionary *currentFilterYearDictionary;

@end

@implementation SDCollegeLandingPageViewController

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
    
    //default value for the filter is 2014, assigning this to filter property
    NSString *path = [[NSBundle mainBundle] pathForResource:@"YearsList" ofType:@"plist"];
    NSArray *yearDictionaryArray = [[NSArray alloc] initWithContentsOfFile:path];
    self.currentFilterYearDictionary = [yearDictionaryArray objectAtIndex:1];
    
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
    self.screenName = @"Team Landing screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataArray count] || self.pagingEndReached) {
        NSString *identifier = @"SDLandingPageCollegeCellIdentifier";
        SDLandingPageCollegeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = (id)[SDLandingPageCollegeCell loadInstanceFromNib];
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
        cell.backgroundColor = [UIColor clearColor];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityViewStyle];
        activityView.center = cell.center;
        [cell addSubview:activityView];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.dataDownloadInProgress) {
            //data downloading not in progress, we can start downloading further pages
            [self checkServer];
            [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Show_More_CollegeLandingPage"];
        }
        return cell;
    }
}

#pragma mark - Filter button actions

- (void)hideFilterView
{
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.teamSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y - frame.size.height;
        self.teamSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
        [self.teamSearchView removeFromSuperview];
        self.teamSearchView = nil;
    }];
    
    //we should tell that filter view was hidden by not using the filter button, so navigation controller could know the state.
    [((SDNavigationController *)self.navigationController)  filterViewBecameHidden];
}

- (int)heightForFilterHidingButton
{
    if (self.teamSearchView) {
        return 90;
    }
    else
        return 0;
}

- (void)showFilterView
{
    
    if (!self.teamSearchView) {
        
        SDTeamsSearchHeader *teamSearchView = [[SDTeamsSearchHeader alloc] init];
        teamSearchView.delegate = self;
        self.teamSearchView = teamSearchView;
    }
    
    //hide SDCollegeHeaderView under toolbar
    CGRect frame = self.teamSearchView.frame;
    frame.origin.y = self.searchBarBackground.frame.origin.y - frame.size.height;
    self.teamSearchView.frame = frame;
    
    [self.view addSubview:self.teamSearchView];
    [self updateFilterButtonNames];
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.teamSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y;
        self.teamSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
    }];
}

- (void)updateFilterButtonNames
{
    if (self.teamSearchView) {
        
        //Year button
        if (self.currentFilterYearDictionary)
            [self.teamSearchView.classButton setCustomTitle:[self.currentFilterYearDictionary valueForKey:@"name"]];
        else
            [self.teamSearchView.classButton setCustomTitle:kDefaultYearFilterName];
        
        //State button
        if (self.currentFilterConference)
            [self.teamSearchView.conferencesButton setCustomTitle:self.currentFilterConference.nameFull];
        else
            [self.teamSearchView.conferencesButton setCustomTitle:kDefaultStateConferenceName];
    }
}

#pragma mark - Data downloading

- (void)checkServer
{
    self.dataDownloadInProgress = YES;
    [SDLandingPagesService getTeamsOrderedByDescendingTotalScoreWithPageNumber:(self.currentUserCount/kPageCountForLandingPages)
                                                                      pageSize:kPageCountForLandingPages
                                                                   classString:[self.currentFilterYearDictionary objectForKey:@"name"]
                                                            conferenceIdString:[self.currentFilterConference.identifier stringValue]
                                                                  successBlock:^{
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
    
    if (self.searchBar.text.length < 3) {
        self.pagingEndReached = NO;
        [self checkServer];
    }
    else {
        [self showProgressHudInView:self.view withText:@"Loading"];
        self.dataIsFiltered = YES;
        
        [SDLandingPagesService searchForTeamsWithNameString:self.searchBar.text conferenceIDString:[self.currentFilterConference.identifier stringValue] classString:[self.currentFilterYearDictionary objectForKey:@"name"] successBlock:^{
            [self loadFilteredData];
        } failureBlock:^{
            NSLog(@"Search failed in Collenge landing page");
        }];
    }
}


#pragma mark - Data Fetching

- (void)loadData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeTeam];
    NSPredicate *userYearPredicate = [NSPredicate predicateWithFormat:@"theTeam.teamClass == %@",[self.currentFilterYearDictionary valueForKey:@"name"]];
    NSPredicate *conferencePredicate = (self.currentFilterConference) ? [NSPredicate predicateWithFormat:@"theTeam.conferenceId == %@",self.currentFilterConference.identifier] : nil;
    
    NSPredicate *compoundPredicate = (conferencePredicate) ? [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate,userYearPredicate, conferencePredicate, nil]] : [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate,userYearPredicate, nil]];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
    NSFetchRequest *request = [User MR_requestAllWithPredicate:compoundPredicate inContext:context];
    [request setFetchLimit:self.currentUserCount];
    //set sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theTeam.totalScore" ascending:NO];
    NSSortDescriptor *commitsDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theTeam.numberOfCommits" ascending:NO];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor,commitsDescriptor,nameDescriptor,nil]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    if ([self.dataArray count] < self.currentUserCount) {
        self.pagingEndReached = YES;
    }
    
    [self hideProgressHudInView:self.view];
    [self reloadTableView];
}

- (void)loadFilteredData
{
    NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeTeam];
    //    NSPredicate *userYearPredicate = [NSPredicate predicateWithFormat:@"theTeam.teamClass == %@",[self.currentFilterYearDictionary valueForKey:@"name"]];
    NSPredicate *nameSearchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchBar.text];
    
    //also add self.currentFilterState.code and [self.currentFilterPositionDictionary objectForKey:@"shortName"]
    NSPredicate *compoundPredicate = (self.searchBar.text.length > 0) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate,nameSearchPredicate]] : [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate]];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataArray = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:compoundPredicate inContext:context];
    
    [self reloadTableView];
    [self hideProgressHudInView:self.view];
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
    self.dataIsFiltered = NO;
    self.currentUserCount = kPageCountForLandingPages;
    self.pagingEndReached = NO;
    [self loadData];
}

#pragma mark - SDTeamSearchHeader Delegate

- (void)teamsSearchHeaderPressedConferencesButton:(SDTeamsSearchHeader *)teamsSeachHeader
{
    [self presentFilterListViewWithType:LIST_TYPE_CONFERENCES andSelectedValue:self.currentFilterConference];
}

- (void)teamsSearchHeaderPressedClassButton:(SDTeamsSearchHeader *)teamsSeachHeader;
{
    [self presentFilterListViewWithType:LIST_TYPE_YEARS andSelectedValue:self.currentFilterYearDictionary];
}

- (void)teamsSearchHeaderPressedSearchButton:(SDTeamsSearchHeader *)teamsSeachHeader
{
    self.currentUserCount = 0;
    self.pagingEndReached = NO;
    [self searchFilteredData];
    [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Search_Selected_TeamLandingPage"];
}

#pragma mark - Filter list delegates

- (void)conferenceChosen:(Conference *)conference inFilterListController:(SDFilterListViewController *)filterListViewController
{
    self.currentFilterConference = conference;
}

- (void)yearsChosen:(NSDictionary *)years inFilterListController:(SDFilterListViewController *)filterListViewController
{
    self.currentFilterYearDictionary = years;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SDLandingPageCollegeCell" bundle:nil] forCellReuseIdentifier:@"SDLandingPageCollegeCellIdentifier"];
}

@end