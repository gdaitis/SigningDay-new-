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
#import "SDClaimAccountViewController.h"
#import "SDStandartNavigationController.h"

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
    cell.moreInfoButton.tag = indexPath.row;
    cell.registerButton.tag = indexPath.row;
    
    [cell removeUnnecessaryLabels];
    [cell setupCellWithDictionary:dataDictionary];
    
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
    NSLog(@"self.selectedIndexPathRow = %d",self.selectedIndexPathRow);
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
    
    switch (sender.tag) {
        case SDJoinControllerCellUserType_FAN:

            break;
            
        case SDJoinControllerCellUserType_PARENT:

            break;
            
        case SDJoinControllerCellUserType_PLAYER:

            break;
            
        case SDJoinControllerCellUserType_COACH:

            break;
            
        case SDJoinControllerCellUserType_HIGHSCHOOL:

            break;
            
        default:
            break;
    }
    SDClaimAccountViewController *claimAccountViewController = [[SDClaimAccountViewController alloc] initWithNibName:@"SDClaimAccountViewController" bundle:nil];
    [self.navigationController pushViewController:claimAccountViewController animated:YES];
}

- (void)backPressed:(id)sender
{
    [self.delegate bakcPressedInJoinViewController:self];
}

@end
