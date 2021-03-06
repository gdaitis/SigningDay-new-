//
//  SDFilterListViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDFilterListViewController.h"
#import "SDFilterListCell.h"
#import "UIView+NibLoading.h"
#import "SDLandingPagesService.h"
#import "State.h"
#import "Conference.h"

@interface SDFilterListViewController ()

@end

@implementation SDFilterListViewController

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
    [self.refreshControl removeFromSuperview];
	// Do any additional setup after loading the view.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    switch (self.filterListType) {
        case LIST_TYPE_POSITIONS:
        {
            [self loadPositions];
            break;
        }
        case LIST_TYPE_STATES:
        {
            //data is downloading so showing activity indicator
            [self showProgressHudInView:self.view withText:@"Loading"];
            [SDLandingPagesService getAllStatesSuccessBlock:^{
                [self loadStates];
            } failureBlock:^{
                [self hideProgressHudInView:self.view];
            }];
            break;
        }
        case LIST_TYPE_YEARS:
        {
            [self loadYears];
            break;
        }
        case LIST_TYPE_CONFERENCES:
        {
            //data is downloading so showing activity indicator
            [self showProgressHudInView:self.view withText:@"Loading"];
            
            [SDLandingPagesService getAllConferencesOFullNameWithSuccessBlock:^{
                [self loadConferences];
            } failureBlock:^{
                [self hideProgressHudInView:self.view];
            }];
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    switch (self.filterListType) {
        case LIST_TYPE_POSITIONS:
            self.screenName = @"Filter position list screen";
            break;
        case LIST_TYPE_STATES:
            self.screenName = @"Filter states list screen";
            break;
        case LIST_TYPE_YEARS:
            self.screenName = @"Filter year list screen";
            break;
        case LIST_TYPE_CONFERENCES:
            self.screenName = @"Filter conference list screen";
            break;
            
        default:
            self.screenName = @"Filter list screen";
            break;
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
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDFilterListCellID";
    SDFilterListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDFilterListCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    cell.checkMarkButton.selected = NO;
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    
    //checking wich cell is selected and marking right checkmark
    if (indexPath.row == 0) {
        if (!self.selectedItem) {
            cell.checkMarkButton.selected = YES;
        }
    }
    if ([self.selectedItem isEqual:object])
        cell.checkMarkButton.selected = YES;
    
    //setting cell title depending on listType
    switch (self.filterListType) {
        case LIST_TYPE_POSITIONS:
        {
            if ([[object class] isSubclassOfClass:[NSDictionary class]])
                cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)",[object valueForKey:@"name"],[object valueForKey:@"shortName"]];
            else
                cell.titleLabel.text = kDefaultPositionFilterName;
            break;
        }
        case LIST_TYPE_STATES:
        {
            if ([[object class] isSubclassOfClass:[State class]])
                cell.titleLabel.text = ((State *) object).name;
            else
                cell.titleLabel.text = kDefaultStateFilterName;
            
            break;
        }
        case LIST_TYPE_YEARS:
        {
            if ([[object class] isSubclassOfClass:[NSDictionary class]])
                cell.titleLabel.text = [object valueForKey:@"name"];
            break;
        }
        case LIST_TYPE_CONFERENCES:
        {
            if ([[object class] isSubclassOfClass:[Conference class]])
                cell.titleLabel.text = ((Conference *) object).nameFull;
            else
                cell.titleLabel.text = kDefaultStateConferenceName;
            
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //update table for the user to see what he has selected
    if (![[self.dataArray objectAtIndex:indexPath.row] isEqual:[NSNull null]]) {
        self.selectedItem = [self.dataArray objectAtIndex:indexPath.row];
    }
    else {
        self.selectedItem = nil;
    }
    [tableView reloadData];

    
    //delegate the selection
    switch (self.filterListType) {
        case LIST_TYPE_POSITIONS:
        {
            if (![[self.dataArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                [self.delegate positionChosen:[self.dataArray objectAtIndex:indexPath.row] inFilterListController:self];
            else
                [self.delegate positionChosen:nil inFilterListController:self];
            break;
        }
        case LIST_TYPE_STATES:
        {
            if (![[self.dataArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                [self.delegate stateChosen:[self.dataArray objectAtIndex:indexPath.row] inFilterListController:self];
            else
                [self.delegate stateChosen:nil inFilterListController:self];
            break;
        }
        case LIST_TYPE_YEARS:
        {
            if (![[self.dataArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                [self.delegate yearsChosen:[self.dataArray objectAtIndex:indexPath.row] inFilterListController:self];
            else
                [self.delegate yearsChosen:nil inFilterListController:self];
            
            
            break;
        }
        case LIST_TYPE_CONFERENCES:
        {
            if (![[self.dataArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                [self.delegate conferenceChosen:[self.dataArray objectAtIndex:indexPath.row] inFilterListController:self];
            else
                [self.delegate conferenceChosen:nil inFilterListController:self];
            break;
        }
        default:
            break;
    }

    //will pop view controller after delay, so user could see what he chose
    [self performSelector:@selector(popViewControllerAfterSelection) withObject:nil afterDelay:0.25f];
}

- (void)popViewControllerAfterSelection
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Data Fetching and loading

- (void)loadStates
{
    self.dataArray = nil;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithObjects:[NSNull null], nil];
    [mutableArray addObjectsFromArray:[State MR_findAllSortedBy:@"name" ascending:YES]];
 
    self.dataArray = [[NSArray alloc] initWithArray:mutableArray];
    [self.tableView reloadData];
    [self hideProgressHudInView:self.view];
}

- (void)loadPositions
{
    //array of dictionary objects
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PositionsList" ofType:@"plist"];
    NSArray *positionsArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithObjects:[NSNull null], nil];
    [mutableArray addObjectsFromArray:positionsArray];
    
    self.dataArray = [[NSArray alloc] initWithArray:mutableArray];
    [self.tableView reloadData];
}

- (void)loadYears
{
    //array of dictionary objects
    NSString *path = [[NSBundle mainBundle] pathForResource:@"YearsList" ofType:@"plist"];
    self.dataArray = [[NSArray alloc] initWithContentsOfFile:path];
    [self.tableView reloadData];
}

- (void)loadConferences
{
    self.dataArray = nil;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithObjects:[NSNull null], nil];
    [mutableArray addObjectsFromArray:[Conference MR_findAllSortedBy:@"nameFull" ascending:YES]];
    
    self.dataArray = [[NSArray alloc] initWithArray:mutableArray];
    [self.tableView reloadData];
    [self hideProgressHudInView:self.view];
}

@end
