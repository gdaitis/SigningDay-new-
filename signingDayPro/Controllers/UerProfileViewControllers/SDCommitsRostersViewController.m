//
//  SDCommitsRostersViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 10/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCommitsRostersViewController.h"
#import "SDProfileService.h"
#import "SDLandingPagePlayerCell.h"
#import "UIView+NibLoading.h"
#import "User.h"
#import "Team.h"
#import "HighSchool.h"

@interface SDCommitsRostersViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SDCommitsRostersViewController

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
    // Do any additional setup after loading the view from its nib.
    
    
    if (self.controllerType == CONTROLLER_TYPE_ROSTERS) {
        [self loadRosters];
        [self showProgressHudInView:self.view withText:@"Loading"];
        
        [SDProfileService getRostersForHighSchoolWithIdentifier:self.userIdentifier completionBlock:^{
            [self loadRosters];
            
            [self hideProgressHudInView:self.view];
        } failureBlock:^{
            [self hideProgressHudInView:self.view];
        }];
    }
    else {
        
        [self loadCommits];
        [self showProgressHudInView:self.view withText:@"Loading"];
        
        [SDProfileService getCommitsForTeamWithIdentifier:self.userIdentifier andYearString:self.yearString completionBlock:^{
            [self loadCommits];
            
            [self hideProgressHudInView:self.view];
        } failureBlock:^{
            
            [self hideProgressHudInView:self.view];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDLandingPagePlayerCellIdentifier";
    SDLandingPagePlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDLandingPagePlayerCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        //we dont't have account verified info here
        [cell.accountVerifiedImageView removeFromSuperview];
    }
    
    User *user = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.playerPositionLabel.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
    // Configure the cell...
    [cell setupCellWithUser:user andFilteredData:NO];
    return cell;
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Roster loading

- (void)loadRosters
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    User *highSchoolUser = [User MR_findFirstByAttribute:@"identifier"
                                         withValue:[NSNumber numberWithInt:[self.userIdentifier intValue]]
                                         inContext:context];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"baseScore"
                                                                     ascending:YES];
    self.dataArray = [[highSchoolUser.theHighSchool.rosters allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

#pragma mark - Commits loading

- (void)loadCommits
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    User *teamUser = [User MR_findFirstByAttribute:@"identifier"
                                         withValue:[NSNumber numberWithInt:[self.userIdentifier intValue]]
                                         inContext:context];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"baseScore"
                                                                     ascending:YES];
    NSLog(@"teamUser.theTeam.commits = %@",teamUser.theTeam.commits);
    self.dataArray = [[teamUser.theTeam.commits allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}


@end
