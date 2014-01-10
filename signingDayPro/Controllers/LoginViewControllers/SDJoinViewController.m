//
//  SDJoinViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDJoinViewController.h"
#import "SDJoinCell.h"
#import "UIView+NibLoading.h"
#import "SDNavigationController.h"
#import "SDCustomNavigationToolbarView.h"
#import "SDPlayerSearchViewController.h"
#import "SDClaimRegistrationViewController.h"
#import "SDRegisterViewController.h"
#import "SDStandartNavigationController.h"
#import "SDCoachSearchViewController.h"
#import "SDHighSchoolSearchViewController.h"

#define kContractedHeight 165.0

@interface SDJoinViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int selectedIndexPathRow;

@end

@implementation SDJoinViewController

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
    self.selectedIndexPathRow = -1;
    [self.refreshControl removeFromSuperview];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [(SDStandartNavigationController *)self.navigationController setNavigationTitle:@"Join"];
    
    self.screenName = @"Join screen";

    [self.tableView setAllowsMultipleSelection:NO];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JoinList" ofType:@"plist"];
    self.dataArray = [[NSArray alloc] initWithContentsOfFile:path];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = kContractedHeight;
	if (indexPath.row == self.selectedIndexPathRow) {
        
        NSDictionary *dataDictionary = [self.dataArray objectAtIndex:indexPath.row];
        NSArray *array = [dataDictionary valueForKey:@"AttributeStringArray"];
        
        result += 2*kJoinCellTopBottomOffset;
        for (NSString *string in array) {
            UIFont *font = [UIFont systemFontOfSize:12.0];
            CGSize size = [string sizeWithFont:font
                                constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)];
            result += size.height;
        }
        
	}
    
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"SDJoinCellID";
    
    NSDictionary *dataDictionary = [self.dataArray objectAtIndex:indexPath.row];
    
    SDJoinCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = (SDJoinCell *)[SDJoinCell loadInstanceFromNib];
        [cell.moreInfoButton addTarget:self action:@selector(moreInfoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.registerButton addTarget:self action:@selector(registerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *buttonTitle = (self.selectedIndexPathRow == indexPath.row) ? @"Less info" : @"More info";
    [cell.moreInfoButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    [cell setupCellWithDictionary:dataDictionary];
    [cell removeUnnecessaryLabels];
    
    if (self.selectedIndexPathRow == indexPath.row)
        [cell setAdditionalAttributeArray:[dataDictionary valueForKey:@"AttributeStringArray"]]; //expanded cell
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateTableView];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateTableView];
}

- (void)updateTableView
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)moreInfoButtonPressed:(UIButton *)sender
{
    if (self.selectedIndexPathRow != -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedIndexPathRow inSection:0];
        self.selectedIndexPathRow = (self.selectedIndexPathRow == sender.tag) ? -1 : sender.tag;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
        self.selectedIndexPathRow = (self.selectedIndexPathRow == sender.tag) ? -1 : sender.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateTableView];
}

- (void)registerButtonPressed:(UIButton *)sender
{
    id viewController = nil;
    
    switch (sender.tag) {
        case SDJoinControllerCellUserType_FAN: {
            SDRegisterViewController *rvc = [[SDRegisterViewController alloc] init];
            viewController = rvc;
            break;
        }
        case SDJoinControllerCellUserType_PARENT: {
            
            SDPlayerSearchViewController *playerSearchViewController = [[SDPlayerSearchViewController alloc] initWithNibName:@"SDCommonUserSearchViewController" bundle:nil];
            playerSearchViewController.userType = SDUserTypePlayer;
            viewController = playerSearchViewController;
            break;
        }
        case SDJoinControllerCellUserType_PLAYER: {
            SDPlayerSearchViewController *playerSearchViewController = [[SDPlayerSearchViewController alloc] initWithNibName:@"SDCommonUserSearchViewController" bundle:nil];
            playerSearchViewController.userType = SDUserTypePlayer;
            viewController = playerSearchViewController;
            break;
        }
        case SDJoinControllerCellUserType_COACH: {
            SDCoachSearchViewController *coachSearchViewController = [[SDCoachSearchViewController alloc] initWithNibName:@"SDCommonUserSearchViewController" bundle:nil];
            coachSearchViewController.userType = SDUserTypeCoach;
            viewController = coachSearchViewController;
            break;
        }
        case SDJoinControllerCellUserType_HIGHSCHOOL: {
            SDHighSchoolSearchViewController *highSchoolSearchViewController = [[SDHighSchoolSearchViewController alloc] initWithNibName:@"SDCommonUserSearchViewController" bundle:nil];
            highSchoolSearchViewController.userType = SDUserTypeHighSchool;
            viewController = highSchoolSearchViewController;
            break;
        }
        default:
            break;
    }
    if (viewController)
        [self.navigationController pushViewController:viewController animated:YES];
    
//    SDClaimAccountViewController *claimAccountViewController = [[SDClaimAccountViewController alloc] initWithNibName:@"SDClaimAccountViewController" bundle:nil];
//    [self.navigationController pushViewController:claimAccountViewController animated:YES];
    
//    SDRegisterViewController *rvc = [[SDRegisterViewController alloc] init];
//    rvc.userType = SDUserTypeMember;
//    [self.navigationController pushViewController:rvc animated:YES];
    
//    SDClaimRegistrationViewController *crvc = [[SDClaimRegistrationViewController alloc] init];
//    [self.navigationController pushViewController:crvc animated:YES];
}

- (void)backPressed:(id)sender
{
    [self.delegate bakcPressedInJoinViewController:self];
}

@end
