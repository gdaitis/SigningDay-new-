//
//  SDFilterListViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDFilterListViewController.h"
#import "SDFilterListCell.h"
#import "UIView+NibLoading.h"

@interface SDFilterListViewController ()

@end

@implementation SDFilterListViewController

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
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SDFilterListCellID";
    SDFilterListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (id)[SDFilterListCell loadInstanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.titleLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.checkMarkButton.selected = NO;
    if (self.selectedRow == indexPath.row)
        cell.checkMarkButton.selected = YES;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    [tableView reloadData];
    //delegate selected value
    
//    [self.delegate didSelectSomeValue];
    
}

@end
