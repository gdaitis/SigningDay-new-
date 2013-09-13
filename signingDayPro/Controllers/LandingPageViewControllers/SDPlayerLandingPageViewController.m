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
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [SDLandingPagesService getPlayersOrderedByDescendingBaseScoreFrom:self.currentUserCount to:self.currentUserCount+10 successBlock:^{
        self.currentUserCount +=10;
        [self loadData];
    } failureBlock:^{
        
    }];
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
    NSString *identifier = @"SDLandingPagePlayerCellIdentifier";
    SDLandingPagePlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDLandingPagePlayerCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    // Configure the cell...
    //cancel previous requests and set user image
    [cell.userImageView cancelImageRequestOperation];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    [cell setupCellWithUser:user];
    return cell;
}

#pragma mark - Filter button actions

- (void)hideFilterView
{
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.playerSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
        self.playerSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
        [self.playerSearchView removeFromSuperview];
    }];
    
    //we should tell that filter view was hidden by not using the filter button, so navigation controller could know the state.
    [((SDNavigationController *)self.navigationController) filterViewBecameHidden];
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
    frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
    self.playerSearchView.frame = frame;
    
    [self updateFilterButtonNames];
    
    [self.view addSubview:self.playerSearchView];
    
    //bring searchBar view to front so the filter SDPlayerSearchHeader would be behind this view
    [self.view bringSubviewToFront:self.searchBarBackground];
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.playerSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height;
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

#pragma mark - Data loading

- (void)loadData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypePlayer];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
    NSFetchRequest *request = [User MR_requestAllWithPredicate:predicate inContext:context];
    [request setFetchLimit:self.currentUserCount];
    //set sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.baseScore" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    [self.tableView reloadData];
}

- (void)loadFilteredData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypePlayer];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
    NSFetchRequest *request = [User MR_requestAllWithPredicate:predicate inContext:context];
    [request setFetchLimit:self.currentUserCount];
    //set sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.baseScore" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    [self.tableView reloadData];
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
    [self hideFilterView];
    [self showProgressHudInView:self.view withText:@"Loading"];
    
#warning check if no filters or text just load simple list, else load filteredData
    
    [SDLandingPagesService searchForPlayersWithNameString:self.searchBar.text stateCodeStringsArray:[NSArray arrayWithObject:self.currentFilterState.code] classYearsStringsArray:[NSArray arrayWithObject:[self.currentFilterYearDictionary objectForKey:@"name"]] positionStringsArray:[NSArray arrayWithObject:[self.currentFilterPositionDictionary objectForKey:@"shortName"]] successBlock:^{
        [self loadFilteredData];
    } failureBlock:^{
        
    }];
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

@end
