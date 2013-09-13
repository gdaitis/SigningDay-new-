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


@interface SDHighSchoolLandingPageViewController () <UITableViewDataSource, UITableViewDelegate,SDHighSchoolSearchHeaderDelegate,SDFilterListDelegate>

@property (nonatomic, strong) SDHighSchoolsSearchHeader *highSchoolSearchView;
@property (nonatomic, strong) State *currentFilterState;

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
    [SDLandingPagesService getPlayersOrderedByDescendingBaseScoreFrom:self.currentUserCount to:self.currentUserCount+10 successBlock:^{
        self.currentUserCount +=10;
        [self loadData];
    } failureBlock:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDLandingPagePlayerCellIdentifier";
    SDLandingPageHighSchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDLandingPageHighSchoolCell loadInstanceFromNib];
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
        CGRect frame = self.highSchoolSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
        self.highSchoolSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
        [self.highSchoolSearchView removeFromSuperview];
    }];
    
    //we should tell that filter view was hidden by not using the filter button, so navigation controller could know the state.
    [((SDNavigationController *)self.navigationController)  filterViewBecameHidden];
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
    frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
    self.highSchoolSearchView.frame = frame;
    
    [self.view addSubview:self.highSchoolSearchView];
    
    [self updateFilterButtonNames];
    
    //bring searchBar view to front so the filter SDHighSchoolHeaderView would be behind this view
    [self.view bringSubviewToFront:self.searchBarBackground];
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.highSchoolSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height;
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

#pragma mark - Data loading

- (void)loadData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeHighSchool];
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


- (void)highSchoolSearchHeaderPressedStatesButton:(SDHighSchoolsSearchHeader *)highSchoolSearchHeader
{
    [self presentFilterListViewWithType:LIST_TYPE_STATES andSelectedValue:self.currentFilterState];
}

- (void)highSchoolSearchHeaderPressedSearchButton:(SDHighSchoolsSearchHeader *)highSchoolSearchHeader
{
//    [self presentFilterListViewWithListData:[NSArray arrayWithObjects:@"sde", nil] andSelectedRow:0];
}

#pragma mark - Filter list delegates

- (void)stateChosen:(State *)state inFilterListController:(SDFilterListViewController *)filterListViewController
{
    self.currentFilterState = state;
}

@end