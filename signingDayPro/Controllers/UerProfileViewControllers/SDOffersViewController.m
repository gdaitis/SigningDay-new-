//
//  SDOffersViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/23/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDOffersViewController.h"

#import "User.h"
#import "Player.h"
#import "Offer.h"
#import "Team.h"
#import "SDProfileService.h"
#import "SDOfferCell.h"
#import "UIView+NibLoading.h"
#import "SDUserProfileViewController.h"
#import "SDCustomNavigationToolbarView.h"
#import "SDNavigationController.h"
#import "IIViewDeckController.h"
#import "SDOfferEditCell.h"
#import "SDCollegeSearchViewController.h"
#import "SDUtils.h"

@interface SDOffersViewController () <UITableViewDataSource,UITableViewDelegate,SDCollegeSearchViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) Offer *commitedToOffer;

@end

@implementation SDOffersViewController

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
    
    
    //set navigation Title to show title instead of buttons in navigationBar
    self.navigationTitle = @"Offers";
    
    [self.refreshControl removeFromSuperview];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableStyle = TABLE_STYLE_NORMAL;
    
    //show college list with offers
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addEditButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeEditButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Offers screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int result = (self.tableStyle == TABLE_STYLE_EDIT) ? [self.dataArray count]+1 : [self.dataArray count];
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataArray count]) {
        
        Offer *offer = [self.dataArray objectAtIndex:indexPath.row];
        
        if (!self.tableStyle == TABLE_STYLE_EDIT) {
            NSString *identifier = @"SDOfferCellID";
            SDOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                cell = (id)[SDOfferCell loadInstanceFromNib];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            [cell setupCellWithOffer:offer];
            
            return cell;
        }
        else {
            NSString *identifier = @"SDOfferEditCellID";
            SDOfferEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                cell = (id)[SDOfferEditCell loadInstanceFromNib];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            BOOL commited = ([offer isEqual:self.commitedToOffer]) ? YES : NO;
            [cell setupCellWithOffer:offer andPlayerCommitted:commited];
            
            return cell;
        }
    }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellID"];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"Add new";
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.tableStyle == TABLE_STYLE_EDIT) {
        if (indexPath.row < [self.dataArray count]) {
            Offer *selectedOffer = [self.dataArray objectAtIndex:indexPath.row];
            self.commitedToOffer = ([selectedOffer isEqual:self.commitedToOffer]) ? nil : selectedOffer;
            [tableView reloadData];
        }
        else {
            //show team selection controller
            SDCollegeSearchViewController *collegeSearchViewController = [[SDCollegeSearchViewController alloc] initWithNibName:@"SDCollegeSearchViewController" bundle:[NSBundle mainBundle]];
            collegeSearchViewController.delegate = self;
            
            collegeSearchViewController.collegeYear = (self.currentUser.thePlayer.userClass) ? self.currentUser.thePlayer.userClass : [SDUtils currentYear];
            [self.navigationController pushViewController:collegeSearchViewController animated:YES];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        Offer *offer = [self.dataArray objectAtIndex:indexPath.row];
        UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                            bundle:nil];
        SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        userProfileViewController.currentUser = offer.team.theUser;
        
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
}


#pragma mark - Data loading

- (void)loadData
{
    [self showProgressHudInView:self.tableView withText:@"Loading"];
    [SDProfileService getOffersForUser:self.currentUser completionBlock:^{
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"playerCommited" ascending:NO];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"team.theUser.name"
                                                                         ascending:YES];
        self.dataArray = nil;
        self.dataArray = [NSMutableArray arrayWithArray:[[self.currentUser.thePlayer.offers allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nameDescriptor, nil]]];
        
        [self.tableView reloadData];
        [self hideProgressHudInView:self.tableView];
        
        if ([self.dataArray count] == 0)
            [self showNoOffersLabel];
        else
            [self findOfferInArray:self.dataArray];
    } failureBlock:^{
        [self hideProgressHudInView:self.tableView];
    }];
}

#pragma mark - Additional functions

- (void)showNoOffersLabel
{
    int labelHeight = 200;
    UILabel *offersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.navigationController.view.frame.size.height/2) - (labelHeight/2), self.view.frame.size.width, labelHeight)];
    offersLabel.textAlignment = NSTextAlignmentCenter;
    offersLabel.backgroundColor = [UIColor clearColor];
    offersLabel.font = [UIFont systemFontOfSize:24];
    offersLabel.center = CGPointMake(160, self.navigationController.view.frame.size.height/2);
    offersLabel.numberOfLines = 0;
    offersLabel.textColor = [UIColor blackColor];
    offersLabel.text = [NSString stringWithFormat:@"%@ does not have any offers yet.",self.currentUser.name];
    
    [self.view addSubview:offersLabel];
}

- (void)updateButtonTitleAndSetImage
{
    SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
    
    UIImage *imageName = (self.tableStyle == TABLE_STYLE_NORMAL) ? [UIImage imageNamed:@"EditButton.png"] : [UIImage imageNamed:@"SaveButton.png"];
    [navigationController.topToolBar setrightButtonImage:imageName];

}

#pragma mark - Edit action

- (void)addEditButton
{
    if ([self.currentUser.identifier isEqualToNumber:[self getMasterIdentifier]]) {
        self.viewDeckController.panningMode = IIViewDeckNoPanning;
        SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
        
        [navigationController.topToolBar.rightButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        navigationController.topToolBar.rightButton.hidden = NO;
        [self updateButtonTitleAndSetImage];
    }
}

- (void)removeEditButton
{
    if ([self.currentUser.identifier isEqualToNumber:[self getMasterIdentifier]]) {
        self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
        SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
        [navigationController.topToolBar.rightButton removeTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [navigationController.topToolBar.rightButton setImage:nil forState:UIControlStateNormal];
        navigationController.topToolBar.rightButton.hidden = YES;
    }
}

- (void)findOfferInArray:(NSArray *)array
{
    for (Offer *offer in array)
    {
        if ([offer.playerCommited boolValue]) {
            self.commitedToOffer = offer;
        }
    }
}

- (void)editButtonPressed:(UIButton *)sender
{
    if (self.tableStyle == TABLE_STYLE_NORMAL) {
        self.tableStyle = TABLE_STYLE_EDIT;
    }
    else {
        self.tableStyle = TABLE_STYLE_NORMAL;
        [self saveUpdates];
    }
    
    [self updateButtonTitleAndSetImage];
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL result = (self.tableStyle == TABLE_STYLE_EDIT) ? YES : NO;
    
    if (indexPath.row >= [self.dataArray count])
        result = NO;
    
    return result;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self deleteOffer:[self.dataArray objectAtIndex:indexPath.row]];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView endUpdates];
    }
}

- (void)deleteOffer:(Offer *)offer
{
    if (offer) {
        
        if ([offer isEqual:self.commitedToOffer])
            self.commitedToOffer = nil;
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        [context deleteObject:offer];
        [context MR_saveOnlySelfAndWait];
    }
}

- (void)saveUpdates
{
    [self showProgressHudInView:self.view withText:@"Saving"];
    //save changes to database and do a request to server with changes
    if (self.commitedToOffer) {
        for (Offer *offer in self.dataArray) {
            if (![offer isEqual:self.commitedToOffer])
                offer.playerCommited = [NSNumber numberWithBool:NO];
            else
                offer.playerCommited = [NSNumber numberWithBool:YES];
        }
    }
    else {
        for (Offer *offer in self.dataArray) {
            offer.playerCommited = [NSNumber numberWithBool:NO];
        }
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [context MR_saveOnlySelfAndWait];
    [self updateServerInfo];
}

- (void)cantSaveOffers
{
    self.tableStyle = TABLE_STYLE_NORMAL;
    [self editButtonPressed:nil];
    
    [self hideProgressHudInView:self.view];
    [self showAlertWithTitle:nil andText:@"An error occurred. Please try again later."];
}

- (void)offersSaved
{
    [self hideProgressHudInView:self.view];
}

- (void)updateServerInfo
{
    //    { Teams: [{TeamId: 2182, Commited: true}, {TeamId: 2143, Commited: false}] }

    NSMutableString *dataString = [NSMutableString stringWithFormat:@"{Teams:["];

    int commitedValidator = 0;
    if ([self.dataArray count] > 0) {
        for (int i = 0; i < [self.dataArray count]; i++) {
            
            Offer *offer = [self.dataArray objectAtIndex:i];
            [dataString appendFormat:@"{TeamId:%d,",[offer.team.theUser.identifier intValue]];
            if ([offer.playerCommited boolValue]) {
                [dataString appendFormat:@"Commited:true}"];
                commitedValidator ++;
            }
            else
                [dataString appendFormat:@"Commited:false}"];
            
            if (i+1 != [self.dataArray count])
                [dataString appendFormat:@","];
        }
    }
    [dataString appendFormat:@"]}"];
    if (commitedValidator > 1) {
        //user can't be commited to more than one team
        [self cantSaveOffers];
    }
    else {
        [SDProfileService saveUsersOffersFromString:dataString completionBlock:^{
            [self offersSaved];
        } failureBlock:^{
            [self cantSaveOffers];
        }];
    }
}

#pragma mark - SDCollegeSearchControllerDelegate

- (void)collegeSearchViewController:(SDCollegeSearchViewController *)collegeSearchController didSelectCollegeUser:(User *)teamUser
{
    if (!teamUser || !teamUser.identifier)
        return;
    
    for (Offer *offer in self.dataArray) {
        if ([offer.team.theUser.identifier isEqualToNumber:teamUser.identifier])
            return; //team already exists in the list
    }
    
    //if team doesn't exist, creating team offer and saving to DB
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    Offer *offer = [Offer MR_createInContext:context];
    offer.team = teamUser.theTeam;
    offer.player = self.currentUser.thePlayer;
    offer.playerCommited = [NSNumber numberWithBool:NO];
    
    [self.dataArray addObject:offer];
    [context MR_saveOnlySelfAndWait];
    [self.tableView reloadData];
}

@end
