//
//  SDOffersViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/23/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDOffersViewController.h"

#import "User.h"
#import "SDProfileService.h"

@interface SDOffersViewController ()

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
    
    //show college list with offers
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    id result = nil;

//            NSString *identifier = @"SDGroupCellID";
//            SDGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            
//            if (!cell) {
//                cell = (id)[SDGroupCell loadInstanceFromNib];
//                cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                cell.backgroundColor = [UIColor clearColor];
//            }
//            
//            id group = [self.dataArray objectAtIndex:indexPath.row];
//            // Configure the cell...
//            [cell setupCellWithGroup:group];
//            
//            result = cell;
//            break;
    
    return result;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Data loading

- (void)loadData
{
    [SDProfileService getOffersForUser:self.currentUser completionBlock:^{

    } failureBlock:^{
        
    }];
}

@end
