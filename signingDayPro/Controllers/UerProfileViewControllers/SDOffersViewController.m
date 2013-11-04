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

@interface SDOffersViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;

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
    
    [self.refreshControl removeFromSuperview];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //show college list with offers
    [self loadData];
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
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = @"SDOfferCellID";
    SDOfferCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDOfferCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    [cell setupCellWithOffer:[self.dataArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Offer *offer = [self.dataArray objectAtIndex:indexPath.row];
    UIStoryboard *userProfileViewStoryboard = [UIStoryboard storyboardWithName:@"UserProfileStoryboard"
                                                                        bundle:nil];
    SDUserProfileViewController *userProfileViewController = [userProfileViewStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.currentUser = offer.team.theUser;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}


#pragma mark - Data loading

- (void)loadData
{
    [self showProgressHudInView:self.tableView withText:@"Loading"];
    [SDProfileService getOffersForUser:self.currentUser completionBlock:^{
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"playerCommited" ascending:NO];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"team.theUser.name"
                                                                         ascending:YES];
        
        self.dataArray = [[self.currentUser.thePlayer.offers allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nameDescriptor, nil]];
        
        [self.tableView reloadData];
        [self hideProgressHudInView:self.tableView];
        
        if ([self.dataArray count] == 0)
            [self showNoOffersLabel];
        
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


@end
