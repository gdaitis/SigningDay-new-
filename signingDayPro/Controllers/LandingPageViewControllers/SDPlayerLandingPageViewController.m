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
#import "SDPlayersSearchHeader.h"
#import "UIView+NibLoading.h"
#import "SDNavigationController.h"

@interface SDPlayerLandingPageViewController () <UITableViewDataSource, UITableViewDelegate,SDPlayersSearchHeaderDelegate>

@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic, strong) SDPlayersSearchHeader *playerSearchView;

- (void)followButtonPressed:(UIButton *)sender;

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDLandingPagePlayerCellIdentifier";
    SDLandingPagePlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDLandingPagePlayerCell loadInstanceFromNib];
        [cell.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    cell.followButton.tag = indexPath.row;
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    // Configure the cell...
    [cell setupCellWithUser:user];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
        CGRect frame = self.playerSearchView.frame;
        frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
        self.playerSearchView.frame = frame;
    } completion:^(__unused BOOL finished) {
        [self.playerSearchView removeFromSuperview];
    }];
    
    //we should tell that filter view was hidden by not using the filter button, so navigation controller could know the state.
    [((SDNavigationController *)self.navigationController)  filterViewBecameHidden];
}

- (void)showFilterView
{
    SDPlayersSearchHeader *playerHeaderView = (SDPlayersSearchHeader *)[SDPlayersSearchHeader loadInstanceFromNib];
    playerHeaderView.delegate = self;
    
    //hide SDPlayerSearchHeader under toolbar
    CGRect frame = playerHeaderView.frame;
    frame.origin.y = self.searchBarBackground.frame.origin.y + self.searchBarBackground.frame.size.height - frame.size.height;
    playerHeaderView.frame = frame;
    
    self.playerSearchView = playerHeaderView;
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

#pragma mark - SDPlayersSearchHeader Delegate

- (void)playersSearchHeaderPressedStatesButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self hideFilterView];
}

- (void)playersSearchHeaderPressedYearsButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self hideFilterView];
}

- (void)playersSearchHeaderPressedPositionsButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self hideFilterView];
}

- (void)playersSearchHeaderPressedSearchButton:(SDPlayersSearchHeader *)playersSearchHeader
{
    [self hideFilterView];
}

@end
