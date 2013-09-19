//
//  SDMenuViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDMenuViewController.h"
#import "SDMenuLabel.h"
#import "SDSearchBar.h"
#import "SDMenuItemCell.h"
#import "User.h"
#import "Master.h"
#import "SDTableView.h"
#import "SDImageService.h"
#import "SDUserProfileViewController.h"
#import "UIImage+Crop.h"

#define kHeaderSize  40

@interface SDMenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, weak) IBOutlet SDSearchBar *searchBar;
@property (nonatomic, weak) IBOutlet SDTableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *keyboardHiddingButton; //hides keyboard, is hidden until searchbar clicked.

- (IBAction)hideKeyboard:(UIButton *)sender;
- (void)dismissKeyboard;

@end

@implementation SDMenuViewController

@synthesize menuItems = _menuItems;
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;

- (void)awakeFromNib
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MenuItemList" ofType:@"plist"];
    self.menuItems = [[NSArray alloc] initWithContentsOfFile:path];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl removeFromSuperview];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserUpdated) name:kUserUpdatedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _keyboardHiddingButton.hidden = YES;
    self.viewDeckController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //First for user, second for menu item list, third for settings
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int result = kHeaderSize;
    if (section == 0) {
        result = 0;
    }
    return result;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //creating view with label
    UIView *result = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kHeaderSize)];
    result.backgroundColor = [UIColor clearColor];
    SDMenuLabel *lbl = [[SDMenuLabel alloc] initWithFrame:CGRectMake(10, 5, result.frame.size.width-20, result.frame.size.height)];
    lbl.textColor = [UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1.0f];
    lbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    lbl.shadowColor = [UIColor clearColor];
    [result addSubview:lbl];
    
    //adding bottom gray line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 38, 254, 2)];
    lineView.backgroundColor = [UIColor colorWithRed:53.0f/255.0f green:53.0f/255.0f blue:53.0f/255.0f alpha:1.0f];
    [result addSubview:lineView];
    
    if (section == 0) {
        lbl.text = @"";
    }
    else if (section == 1) {
        lbl.text = @"NAVIGATION";
    }
    else {
        lbl.text = @"SETTINGS & PRIVACY POLICY";
    }
    
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    int result = 1;
    if (sectionIndex == 1) {
        result = self.menuItems.count;
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDMenuItemCell *cell = nil;
    NSString *cellIdentifier = @"SDMenuItemCellID";
    
    cell = (SDMenuItemCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Load cell
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDMenuItemCell" owner:nil options:nil];
        // Grab cell reference which was set during nib load:
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDMenuItemCell class]]) {
                cell = currentObject;
                break;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    [self setupCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)setupCell:(SDMenuItemCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        User *user = [self getMasterUser];
        
        if (user) {
            cell.txtLabel.text = user.name;
            [[SDImageService sharedService] getImageWithURLString:user.avatarUrl success:^(UIImage *image) {
                if (image != cell.imgView.image) {
                    cell.imgView.image = image;
                }
            }];
        }
        else {
            cell.txtLabel.text = nil;
            cell.imgView.image = nil;
        }
        cell.txtLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        cell.txtLabel.textColor = [UIColor colorWithRed:228.0f/255.0f green:196.0f/255.0f blue:21.0f/255.0f alpha:1.0f];
        
        cell.bottomLineView.backgroundColor = [UIColor clearColor];
    }
    else if (indexPath.section == 1) {
        cell.txtLabel.text = [[_menuItems objectAtIndex:indexPath.row] valueForKey:@"Title"];
        cell.imgView.image = [UIImage imageNamed:[[_menuItems objectAtIndex:indexPath.row] valueForKey:@"Image"]];
        cell.txtLabel.textColor = [UIColor whiteColor];
        
        if (indexPath.row == [_menuItems count] - 1)
            cell.bottomLineView.backgroundColor = [UIColor clearColor];
        else
            cell.bottomLineView.backgroundColor = [UIColor colorWithRed:37.0f/255.0f green:37.0f/255.0f blue:37.0f/255.0f alpha:1];
    }
    else {
        cell.txtLabel.text = @"Settings";
        cell.txtLabel.textColor = [UIColor whiteColor];
        cell.imgView.image = [UIImage imageNamed:@"SettingsIcon.png"];
        
        cell.bottomLineView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *centerVC = nil;
    
    if (indexPath.section == 0) {
        //show profile view controller
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"UserProfileStoryboard" bundle:nil];
        centerVC = [sb instantiateViewControllerWithIdentifier:@"SDViewNavigationController"];
        
        SDUserProfileViewController *userProfileController = [((UINavigationController *)centerVC).viewControllers lastObject];
        userProfileController.currentUser = [self getMasterUser];
    }
    else if (indexPath.section == 1) {
        //show controller depending on selection
        
        if (indexPath.row == 0) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ActivityFeedStoryboard" bundle:nil];
            centerVC = [sb instantiateViewControllerWithIdentifier:@"SDActivityFeedNavigationController"];
        }
        else if (indexPath.row == 1) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LandingPageStoryBoard" bundle:nil];
            centerVC = [sb instantiateViewControllerWithIdentifier:@"PlayerLandingPageViewController"];
        }
        else if (indexPath.row == 2) { //colleges
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LandingPageStoryBoard" bundle:nil];
            centerVC = [sb instantiateViewControllerWithIdentifier:@"CollegesLandingPageViewController"];
        }
        else if (indexPath.row == 3) { //war room
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LandingPageStoryBoard" bundle:nil];
            centerVC = [sb instantiateViewControllerWithIdentifier:@"PlayerLandingPageViewController"];
        }
        else if (indexPath.row == 4) { //highscool
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LandingPageStoryBoard" bundle:nil];
            centerVC = [sb instantiateViewControllerWithIdentifier:@"HighSchoolLandingPageNavigationController"];
        }
        else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LandingPageStoryBoard" bundle:nil];
            centerVC = [sb instantiateViewControllerWithIdentifier:@"PlayerLandingPageViewController"];
        }
    }
    else {
        //show settings controller
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
        centerVC = [sb instantiateViewControllerWithIdentifier:@"SDSettingsNavigationController"];
    }
    
    self.viewDeckController.centerController = centerVC;
    [self.viewDeckController showCenterView:YES];
}

#pragma mark - UISearchDisplayController delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [self filterContentForSearchText:searchString];
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
//    [self reloadView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
//    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SDFollowingCell" bundle:nil] forCellReuseIdentifier:@"FollowingCellID"];
}


#pragma mark - searchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _keyboardHiddingButton.hidden = NO;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self dismissKeyboard];
    
    //search actions
    
}

#pragma mark - IBActions

- (IBAction)hideKeyboard:(UIButton *)sender
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
    _keyboardHiddingButton.hidden = YES;
}

#pragma mark - IIViewDeckController delegate

- (BOOL)viewDeckControllerWillCloseLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated
{
    [self dismissKeyboard];
    return YES;
}

#pragma mark - NSNotif center updates

- (void)UserUpdated
{
    [_tableView reloadData];
}

@end
