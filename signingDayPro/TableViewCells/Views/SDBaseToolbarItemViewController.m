//
//  SDBaseToolbarItemViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseToolbarItemViewController.h"

@interface SDBaseToolbarItemViewController ()

@end

@implementation SDBaseToolbarItemViewController

@synthesize dataArray = _dataArray;
@synthesize tableView = _tableView;

- (NSArray *)dataArray
{
    if (!_dataArray) {
        self.dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}

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
    
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.84f alpha:1.0f]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.frame = CGRectMake(0, kBaseToolbarItemViewControllerHeaderHeight, self.view.bounds.size.width, self.view.bounds.size.height - kBaseToolbarItemViewControllerHeaderHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBaseToolbarItemViewControllerRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.dataArray count];
}

@end
