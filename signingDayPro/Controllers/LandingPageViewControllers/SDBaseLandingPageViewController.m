//
//  SDBaseLandingPageViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseLandingPageViewController.h"
#import "SDLandingPageSearchBar.h"
#import "SDNavigationController.h"

#define kHideKeyboardTag 999

@interface SDBaseLandingPageViewController () <UISearchBarDelegate>


@end

@implementation SDBaseLandingPageViewController

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
    [self addSearchBar];
    [self.refreshControl removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFilter:) name:kFilterButtonPressedNotification object:nil];
    [((SDNavigationController *)self.navigationController) addFilterButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFilterButtonPressedNotification object:nil];
    [((SDNavigationController *)self.navigationController) removeFilterButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSearchBar
{
    UIView *searchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 58)];
    searchBackgroundView.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
    
    SDLandingPageSearchBar *searchB = [[SDLandingPageSearchBar alloc] initWithFrame:CGRectMake(0, 7, 320, 44)];
    self.searchBar = searchB;
    self.searchBar.delegate = self;

    [searchBackgroundView addSubview:self.searchBar];
    self.searchBarBackground = searchBackgroundView;
    [self.view addSubview:self.searchBarBackground];
}

#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UIButton *hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyboardButton.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height);
    
    hideKeyboardButton.tag = kHideKeyboardTag;
    [hideKeyboardButton addTarget:self action:@selector(removeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hideKeyboardButton];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    [self performSearch];
    [self removeKeyboard];
}

- (void)removeKeyboard
{
    
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [(UIButton *)[self.view viewWithTag:kHideKeyboardTag] removeFromSuperview];
    }
}

#pragma mark - FilterButtonActions

- (void)showFilter:(NSNotification *)notification
{
    [self removeKeyboard];
    
    if ([self.searchBar isFirstResponder]) {
        UIButton *keyboardHidingButton = (UIButton *)[self.view viewWithTag:kHideKeyboardTag];
        if (keyboardHidingButton) {
            [self.view bringSubviewToFront:keyboardHidingButton];
        }
    }
    if ([[[notification userInfo] objectForKey:@"hideFilterView"] boolValue]) {
        [self hideFilterView];
    }
    else {
        [self showFilterView];
    }
}

- (void)hideFilterView
{
    
}

- (void)showFilterView
{
    
}

@end