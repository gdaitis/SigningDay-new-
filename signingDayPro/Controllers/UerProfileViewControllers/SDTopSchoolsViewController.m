//
//  SDTopSchoolsViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDTopSchoolsViewController.h"
#import "User.h"
#import "TopSchool.h"
#import "Player.h"
#import "Team.h"
#import "SDCollegeSearchViewController.h"
#import "SDTopSchoolsCell.h"
#import "SDTopSchoolEditCell.h"
#import "UIView+NibLoading.h"
#import "SDUtils.h"
#import "SDUserProfileViewController.h"
#import "SDNavigationController.h"
#import "SDCustomNavigationToolbarView.h"
#import "IIViewDeckController.h"
#import "SDTopSchoolService.h"
#import "SDInterestSelectionView.h"
#import "SDShareView.h"
#import "SDSharingService.h"

@interface SDTopSchoolsViewController () <UITableViewDataSource,UITableViewDelegate,SDCollegeSearchViewControllerDelegate,SDInterestSelectionViewDelegate,SDShareViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *originalList;

@end

@implementation SDTopSchoolsViewController

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
    
    //set navigation Title to show title instead of buttons in navigationBar
    self.navigationTitle = @"Top Schools";
    
    [self.refreshControl removeFromSuperview];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableStyle = TABLE_STYLE_NORMAL;
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
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
    self.screenName = @"Top schools screen";
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
        
        TopSchool *topSchool = [self.dataArray objectAtIndex:indexPath.row];
        
        if (!self.tableStyle == TABLE_STYLE_EDIT) {
            NSString *identifier = @"SDtopSchoolsCellID";
            SDTopSchoolsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                cell = (id)[SDTopSchoolsCell loadInstanceFromNib];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            [cell setupCellWithTopSchool:topSchool atRow:indexPath.row];
            
            return cell;
        }
        else {
            NSString *identifier = @"SDTopSchoolsEditCellID";
            SDTopSchoolEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cell) {
                cell = (id)[SDTopSchoolEditCell loadInstanceFromNib];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
            }
            
            [cell setupCellWithTopSchool:topSchool];
            
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


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL result = (indexPath.row != [self.dataArray count]) ? YES : NO;
    return result;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    TopSchool *topSchool = [self.dataArray objectAtIndex:sourceIndexPath.row];
    [self.dataArray removeObjectAtIndex:sourceIndexPath.row];
    [self.dataArray insertObject:topSchool atIndex:destinationIndexPath.row];
    
//    [tableView reloadData];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
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
        [self deleteTopSchool:[self.dataArray objectAtIndex:indexPath.row]];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView endUpdates];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == self.dataArray.count) {
        return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row-1 inSection:sourceIndexPath.section];
    }
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}


//- (void)moveReorderControl:(UITableViewCell *)cell subviewCell:(UIView *)subviewCell
//{
//    if([[[subviewCell class] description] isEqualToString:@"UITableViewCellReorderControl"]) {
//        static int TRANSLATION_REORDER_CONTROL_Y = -20;
//
//        //Code to move the reorder control, you change change it for your code, this works for me
//        UIView* resizedGripView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,    CGRectGetMaxX(subviewCell.frame), CGRectGetMaxY(subviewCell.frame))];
//        [resizedGripView addSubview:subviewCell];
//        [cell addSubview:resizedGripView];
//
//        //  Original transform
//        const CGAffineTransform transform = CGAffineTransformMakeTranslation(subviewCell.frame.size.width - cell.frame.size.width, TRANSLATION_REORDER_CONTROL_Y);
//        //  Move custom view so the grip's top left aligns with the cell's top left
//
//        [resizedGripView setTransform:transform];
//    }
//}
//
////This method is due to the move cells icons is on right by default, we need to move it.
//- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    for(UIView* subviewCell in cell.subviews)
//    {
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//            if([[[subviewCell class] description] isEqualToString:@"UITableViewCellScrollView"]) {
//                for(UIView* subSubviewCell in subviewCell.subviews) {
//                    [self moveReorderControl:cell subviewCell:subSubviewCell];
//                }
//            }
//        }
//        else{
//            [self moveReorderControl:cell subviewCell:subviewCell];
//        }
//    }
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.tableStyle == TABLE_STYLE_EDIT) {
        if (indexPath.row < [self.dataArray count]) {
            [self showInterestLevelViewForRow:indexPath.row];
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
        TopSchool *topSchool = [self.dataArray objectAtIndex:indexPath.row];
        UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                            bundle:nil];
        SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        userProfileViewController.currentUser = topSchool.theTeam.theUser;
        
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
}


#pragma mark - Data loading

- (void)loadData
{
    [self showProgressHudInView:self.tableView withText:@"Loading"];
    
    [SDTopSchoolService getTopSchoolsForUser:self.currentUser completionBlock:^{
        NSSortDescriptor *rankDescriptor =      [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:YES];
        
        self.dataArray = nil;
        self.dataArray = [NSMutableArray arrayWithArray:[[self.currentUser.thePlayer.topSchools allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:rankDescriptor, nil]]];
        
        [self.tableView reloadData];
        [self hideProgressHudInView:self.tableView];
        if ([self.dataArray count] == 0)
            [self showNoOffersLabel];
        
        
    } failureBlock:^{
        
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

- (void)editButtonPressed:(UIButton *)sender
{
    if (self.tableStyle == TABLE_STYLE_NORMAL) {
        self.tableStyle = TABLE_STYLE_EDIT;
        [self.tableView setEditing:YES];
        [self rememberCurrentListInfoForSharing];
        
    }
    else {
        self.tableStyle = TABLE_STYLE_NORMAL;
        [self.tableView setEditing:NO];
        [self saveUpdates];
    }
    
    [self updateButtonTitleAndSetImage];
    [self.tableView reloadData];
}

- (void)deleteTopSchool:(TopSchool *)topSchool
{
    if (topSchool) {
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        [context deleteObject:topSchool];
        [context MR_saveOnlySelfAndWait];
    }
}

- (void)rememberCurrentListInfoForSharing
{
    //save original(initial) offer
    self.originalList = nil;
    self.originalList = [[NSMutableArray alloc] init];
    
    //save team ids'
    for (TopSchool *topSchool in self.dataArray) {
        [self.originalList addObject:topSchool.theTeam.theUser.identifier];
    }
}

- (void)saveUpdates
{
    for (int i = 0; i< [self.dataArray count]; i++) {
        TopSchool *topSchool = [self.dataArray objectAtIndex:i];
        topSchool.rank = [NSNumber numberWithInt:i+1];
    }
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
    
    NSString *sharingString = [self formShareString];
    if (!sharingString) {
        [self sendUpdatesToServer];
    }
    else {
        [self showSharingViewWithString:sharingString andUser:self.currentUser];
    }
}

- (void)sendUpdatesToServer
{
    [self showProgressHudInView:self.view withText:@"Saving"];
    
    [self.tableView reloadData];
    [self updateServerInfo];
}

- (NSString *)formShareString
{
    //can return nil, caller responsible for checking this
    NSString *result = [self stringForReceivedOffers];
    
    return result;
}

- (NSString *)stringForReceivedOffers
{
    BOOL commitedToAtLeastOneNewTeam = NO;
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"added"];
    for (TopSchool *topSchool in self.dataArray) {
        if (![self.originalList containsObject:topSchool.theTeam.theUser.identifier]) {
            [result appendFormat:@" %@,",topSchool.theTeam.theUser.name];
            commitedToAtLeastOneNewTeam = YES;
        }
    }
    if (commitedToAtLeastOneNewTeam) {
        NSString *substring = [result substringToIndex:result.length -1];
        result = [NSMutableString stringWithString:substring];
        [result appendFormat:@" to his top schools via @Signing_Day %@",kSharingUrlDisplayedText];
    }
    else
        result = nil;
    
    
    return result;
}

- (void)showSharingViewWithString:(NSString *)shareString andUser:(User *)currentUser
{
    //in delegate method sendUpdatesToServer
    
    SDShareView *shareView = (id)[SDShareView loadInstanceFromNib];
    shareView.frame = self.navigationController.view.frame;
    shareView.delegate = self;
    [shareView setUpViewWithShareString:shareString andUser:currentUser];
    shareView.alpha = 0.0f;
    [self.navigationController.view addSubview:shareView];
    
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        shareView.alpha = 1.0f;
    } completion:^(__unused BOOL finished) {
    }];
}

#pragma mark - ShareView Delegate

- (void)shareButtonSelectedInShareView:(SDShareView *)shareView
                         withShareText:(NSString *)shareText
                       facebookEnabled:(BOOL)facebookEnabled
                        twitterEnabled:(BOOL)twitterEnabled
{
    //send share string to fb or tw
    [SDSharingService shareString:shareText
                      forFacebook:facebookEnabled
                       andTwitter:twitterEnabled];
    
    //send edited list to server
    [self sendUpdatesToServer];
    [self removeShareView:shareView];
}

- (void)dontShareButtonSelectedInShareView:(SDShareView *)shareView
{
    //send edited list to server
    [self sendUpdatesToServer];
    [self removeShareView:shareView];
}

- (void)removeShareView:(SDShareView *)shareView
{
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        shareView.alpha = 0.0f;
    } completion:^(__unused BOOL finished) {
        [shareView removeFromSuperview];
    }];
}

- (void)cantSaveTopSchools
{
    self.tableStyle = TABLE_STYLE_NORMAL;
    [self editButtonPressed:nil];
    
    [self hideProgressHudInView:self.view];
    [self showAlertWithTitle:nil andText:@"An error occurred. Please try again later."];
}

- (void)topSchoolsSaved
{
    [self hideProgressHudInView:self.view];
}

- (void)updateServerInfo
{
    NSMutableString *dataString = [NSMutableString stringWithFormat:@"{Teams:["];
    
    if ([self.dataArray count] > 0) {
        for (int i = 0; i < [self.dataArray count]; i++) {
            
            TopSchool *topSchool = [self.dataArray objectAtIndex:i];
            [dataString appendFormat:@"{TeamId:%d, Rank:%d, Interest:%d}",[topSchool.theTeam.theUser.identifier intValue],[topSchool.rank intValue],[topSchool.interest intValue]];
            
            if (i+1 != [self.dataArray count])
                [dataString appendFormat:@","];
        }
    }
    [dataString appendFormat:@"]}"];
    
    [SDTopSchoolService saveTopSchoolsFromString:dataString completionBlock:^{
        [self topSchoolsSaved];
    } failureBlock:^{
        [self cantSaveTopSchools];
    }];
}

#pragma mark - SDCollegeSearchControllerDelegate

- (void)collegeSearchViewController:(SDCollegeSearchViewController *)collegeSearchController didSelectCollegeUser:(User *)teamUser
{
    if (!teamUser || !teamUser.identifier)
        return;
    
    for (TopSchool *topSchool in self.dataArray) {
        if ([topSchool.theTeam.theUser.identifier isEqualToNumber:teamUser.identifier])
            return; //team already exists in the list
    }
    
    //if team doesn't exist, creating team offer and saving to DB
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    TopSchool *topSchool = [TopSchool MR_createInContext:context];
    topSchool.theTeam = teamUser.theTeam;
    topSchool.thePlayer = self.currentUser.thePlayer;
    topSchool.interest = [NSNumber numberWithInt:1];
    topSchool.rank = [NSNumber numberWithInt:[self.dataArray count]+1];
    
    [self.dataArray addObject:topSchool];
    [context MR_saveOnlySelfAndWait];
    [self.tableView reloadData];
}

#pragma mark - Interest level view

- (void)showInterestLevelViewForRow:(int)row
{
    TopSchool *topSchool = [self.dataArray objectAtIndex:row];
    int interest = [topSchool.interest intValue];
    
    SDInterestSelectionView *interestView = (id)[SDInterestSelectionView loadInstanceFromNib];
    interestView.tag = row;
    interestView.frame = self.navigationController.view.frame;
    interestView.delegate = self;
    interestView.alpha = 0.0f;
    [interestView setupButtonColorsWithIndex:interest];
    [self.navigationController.view addSubview:interestView];
    
    interestView.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        interestView.alpha = 1.0f;
        interestView.contentView.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished) {
    }];
}

- (void)removeInterestSelectionView:(SDInterestSelectionView *)interestView
{
    [UIView animateWithDuration:0.25f delay:0.2f options:UIViewAnimationOptionCurveEaseIn animations:^{
        interestView.alpha = 0.0f;
    } completion:^(__unused BOOL finished) {
        [interestView removeFromSuperview];
    }];
}

#pragma mark - Interest Level View Delegate

- (void)interestSelectionView:(SDInterestSelectionView *)interestView interestSelected:(int)interestLevel
{
    TopSchool *topSchool = [self.dataArray objectAtIndex:interestView.tag];
    topSchool.interest = [NSNumber numberWithInt:interestLevel];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
    [self.tableView reloadData];
    [self removeInterestSelectionView:interestView];
}

@end
