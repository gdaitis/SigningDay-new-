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

#define kHeaderSize  40

@interface SDMenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, weak) IBOutlet SDSearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

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
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    SDMenuLabel *lbl = [[SDMenuLabel alloc] initWithFrame:CGRectMake(10, 8, result.frame.size.width-20, result.frame.size.height)];
    lbl.textColor = [UIColor grayColor];
    lbl.font = [UIFont fontWithName:@"BebasNeue" size:18.0];
    [result addSubview:lbl];
    
    //adding bottom gray line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(8, 38, 260, 2)];
    lineView.backgroundColor = [UIColor grayColor];
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
    }
    
    [self setupCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)setupCell:(SDMenuItemCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.txtLabel.text = @"Jalan McClendon";
        cell.txtLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        cell.txtLabel.textColor = [UIColor colorWithRed:228.0f/255.0f green:196.0f/255.0f blue:21.0f/255.0f alpha:1.0f];
        cell.imgView.backgroundColor = [UIColor grayColor];
    }
    else if (indexPath.section == 1) {
        cell.txtLabel.text = [[_menuItems objectAtIndex:indexPath.row] valueForKey:@"Title"];
        cell.imgView.image = [UIImage imageNamed:[[_menuItems objectAtIndex:indexPath.row] valueForKey:@"Image"]];
        cell.txtLabel.textColor = [UIColor whiteColor];
    }
    else {
        cell.txtLabel.text = @"Settings";
        cell.txtLabel.textColor = [UIColor whiteColor];
        cell.imgView.image = [UIImage imageNamed:@"SettingsIcon.png"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDViewController";
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    if (indexPath.section == 0) {
        //show profile view controller
    }
    else if (indexPath.section == 1) {
        //show controller depending on selection
    }
    else {
        //show settings controller
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
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

@end
