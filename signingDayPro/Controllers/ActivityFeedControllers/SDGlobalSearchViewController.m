//
//  SDGlobalSearchViewController.m
//  SigningDay
//
//  Created by lite on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDGlobalSearchViewController.h"

@interface SDGlobalSearchViewController () <UISearchBarDelegate>

@end

@implementation SDGlobalSearchViewController

- (void)loadView
{
    [super loadView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, 320, 40);
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
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

#pragma mark - UISearchBarDelegateMethods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

@end
