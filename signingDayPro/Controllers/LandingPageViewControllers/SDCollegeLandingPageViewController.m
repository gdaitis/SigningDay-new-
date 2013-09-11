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

NSString * const kSDDefaultClass = @"2014";

@interface SDCollegeLandingPageViewController () <UITableViewDataSource, UITableViewDelegate,SDTeamsSearchHeaderDelegate>

@property (nonatomic, strong) SDTeamsSearchHeader *teamSearchView;

- (void)followButtonPressed:(UIButton *)sender;

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
    
    [SDLandingPagesService getTeamsOrderedByDescendingTotalScoreWithPageNumber:self.currentUserCount
                                                                      pageSize:10
                                                                   classString:kSDDefaultClass
                                                                  successBlock:^{
                                                                      self.currentUserCount +=10;
                                                                      [self loadData];
                                                                  } failureBlock:nil];
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

#pragma mark - IBActions

- (void)followButtonPressed:(UIButton *)sender
{
    //    indexpath.row = sender.tag;
    
    sender.selected = !sender.selected;
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
    }];
    
    //we should tell that filter view was hidden by not using the filter button, so navigation controller could know the state.
    [((SDNavigationController *)self.navigationController)  filterViewBecameHidden];
}

- (void)showFilterView
{
    SDTeamsSearchHeader *teamSearchView = [[SDTeamsSearchHeader alloc] init];
    teamSearchView.delegate = self;
    
    //hide SDCollegeHeaderView under toolbar
    CGRect frame = teamSearchView.frame;
    frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
    teamSearchView.frame = frame;
    
    self.teamSearchView = teamSearchView;
    [self.view addSubview:self.teamSearchView];
    
    //bring searchBar view to front so the filter SDCollegeHeaderView would be behind this view
    [self.view bringSubviewToFront:self.searchBarBackground];
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.teamSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height;
        self.teamSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
    }];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thePlayer.baseScore" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];
    
    [self.tableView reloadData];
}

#pragma mark - SDTeamSearchHeader Delegate

- (void)teamsSearchHeaderPressedConferencesButton:(SDTeamsSearchHeader *)teamsSeachHeader
{
    [self presentFilterListViewWithListData:[NSArray arrayWithObjects:@"sde", nil] andSelectedRow:0];
}

- (void)teamsSearchHeaderPressedClassButton:(SDTeamsSearchHeader *)teamsSeachHeader;
{
    [self presentFilterListViewWithListData:[NSArray arrayWithObjects:@"sde", nil] andSelectedRow:0];
}

- (void)teamsSearchHeaderPressedSearchButton:(SDTeamsSearchHeader *)teamsSeachHeader
{
    [self presentFilterListViewWithListData:[NSArray arrayWithObjects:@"sde", nil] andSelectedRow:0];
}

@end