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

NSString * const kSDDefaultClass = @"2014";

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
	// Do any additional setup after loading the view.;
    
    //default value for the filter is 2014, assigning this to filter property
    NSString *path = [[NSBundle mainBundle] pathForResource:@"YearsList" ofType:@"plist"];
    NSArray *yearDictionaryArray = [[NSArray alloc] initWithContentsOfFile:path];
    self.currentFilterYearDictionary = [yearDictionaryArray objectAtIndex:1];
    
    [SDLandingPagesService getTeamsOrderedByDescendingTotalScoreWithPageNumber:self.currentUserCount
                                                                      pageSize:10
                                                                   classString:[self.currentFilterYearDictionary objectForKey:@"name"]
                                                                  successBlock:^{
                                                                      self.currentUserCount +=10;
                                                                      [self loadData];
                                                                  } failureBlock:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDLandingPageCollegeCellIdentifier";
    SDLandingPageCollegeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDLandingPageCollegeCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    // Configure the cell...
    [cell setupCellWithUser:user];
    return cell;
}

#pragma mark - Filter button actions

- (void)hideFilterView
{
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.teamSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
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
    frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
    self.teamSearchView.frame = frame;
    
    [self.view addSubview:self.teamSearchView];
    [self updateFilterButtonNames];
    
    //bring searchBar view to front so the filter SDCollegeHeaderView would be behind this view
    [self.view bringSubviewToFront:self.searchBarBackground];
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.teamSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height;
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

#pragma mark - Data loading

- (void)loadData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeTeam];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
    NSFetchRequest *request = [User MR_requestAllWithPredicate:predicate inContext:context];
    [request setFetchLimit:self.currentUserCount];
    //set sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theTeam.totalScore" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    [self.tableView reloadData];
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
    
    [self.tableView reloadData];
    [self hideProgressHudInView:self.view];
}

- (void)searchFilteredData
{
    [self hideFilterView];
    [self showProgressHudInView:self.view withText:@"Loading"];
    
    [SDLandingPagesService searchForTeamsWithNameString:self.searchBar.text conferenceIDString:[self.currentFilterConference.identifier stringValue] classString:[self.currentFilterYearDictionary objectForKey:@"name"] successBlock:^{
        [self loadFilteredData];
    } failureBlock:^{
        
    }];
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
    [self searchFilteredData];
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

@end