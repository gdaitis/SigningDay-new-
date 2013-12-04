//
//  SDCollegeSearchViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCollegeSearchViewController.h"
#import "SDLandingPageSearchBar.h"
#import "User.h"
#import "SDProfileService.h"
#import "SDLandingPagesService.h"

#define kHideKeyboardButtonTag 999
#define kPageCountForColleges 20

@interface SDCollegeSearchViewController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, weak) SDLandingPageSearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *customSearchDisplayController;
@property (nonatomic, weak) UIView *searchBarBackground;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int currentCollegeCount;
@property (nonatomic, assign) BOOL dataIsFiltered;
@property (nonatomic, assign) BOOL pagingEndReached;
@property (nonatomic, assign) BOOL dataDownloadInProgress;

@end

@implementation SDCollegeSearchViewController

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
    self.navigationTitle = @"Add team";
    
    [self addSearchBar];
    [self loadData];
    [self showProgressHudInView:self.view withText:@"Loading"];
    [self checkServer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int result = 0;
    if (self.pagingEndReached || self.searchBar.text.length > 0 || self.dataIsFiltered) {
        result = [self.dataArray count];
    }
    else {
        result = ([self.dataArray count] == 0) ? 0 : [self.dataArray count]+1;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.searchBar isFirstResponder]) {
        [self removeKeyboard];
    }
    
    [self.delegate collegeSearchViewController:self didSelectCollegeUser:[self.dataArray objectAtIndex:indexPath.row]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder]) {
        [self removeKeyboard];
        //        if (self.searchBar.text.length < 1) {
        //            self.currentCollegeCount = kPageCountForColleges;
        //            self.dataIsFiltered = NO;
        //            self.pagingEndReached = NO;
        //            [self loadData];
        //        }
    }
}

- (void)addSearchBar
{
    if (!self.searchBarBackground) {
        
        float searchBarHeight = 44.0f;
        
        float y = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 20.0 : 0;
        
        UIView *searchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, y+searchBarHeight, self.view.frame.size.width, searchBarHeight)];
        searchBackgroundView.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
        
        SDLandingPageSearchBar *searchB = [[SDLandingPageSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, searchBarHeight)];
        self.searchBar = searchB;
        self.searchBar.delegate = self;
        
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc]
                                                              initWithSearchBar:_searchBar contentsController:self];
        
        self.customSearchDisplayController = searchDisplayController;
        
        _customSearchDisplayController.delegate = self;
        _customSearchDisplayController.searchResultsDataSource = self;
        _customSearchDisplayController.searchResultsDelegate = self;
        
        [searchBackgroundView addSubview:self.searchBar];
        self.searchBarBackground = searchBackgroundView;
        [self.view addSubview:self.searchBarBackground];
        
        CGRect frame = self.tableView.frame;
        frame.origin.y = searchBackgroundView.frame.size.height + searchBackgroundView.frame.origin.y;
        frame.size.height = self.view.frame.size.height - searchBackgroundView.frame.size.height - searchBackgroundView.frame.origin.y;
        self.tableView.frame = frame;
    }
}

#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UIButton *hideKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideKeyboardButton.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height);
    
    hideKeyboardButton.tag = kHideKeyboardButtonTag;
    [hideKeyboardButton addTarget:self action:@selector(removeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:hideKeyboardButton];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (self.searchBar.text.length < 1) {
        self.currentCollegeCount = kPageCountForColleges;
        self.dataIsFiltered = NO;
        self.pagingEndReached = NO;
        [self loadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self removeKeyboard];
    return YES;
}

- (void)removeKeyboard
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [(UIButton *)[self.view viewWithTag:kHideKeyboardButtonTag] removeFromSuperview];
    }
    if ([self.customSearchDisplayController.searchBar isFirstResponder]) {
        [self.customSearchDisplayController.searchBar resignFirstResponder];
        [(UIButton *)[self.view viewWithTag:kHideKeyboardButtonTag] removeFromSuperview];
    }
}

- (void)reloadTableView
{
    if ([_searchBar.text length] > 0) {
        
        //reload searchresultstableview tu update cell
        [_customSearchDisplayController.searchResultsTableView reloadData];
    }
    else {
        [self.tableView reloadData];
    }
}


#pragma mark - Data downloading

- (void)checkServer
{
    self.dataDownloadInProgress = YES;
    [SDLandingPagesService getTeamsOrderedByDescendingTotalScoreWithPageNumber:self.currentCollegeCount pageSize:kPageCountForColleges successBlock:^{
        self.currentCollegeCount += kPageCountForColleges;
        self.dataDownloadInProgress = NO;
        [self loadData];
        
    } failureBlock:^{
        self.dataDownloadInProgress = NO;
    }];
    
//    [SDLandingPagesService getTeamsOrderedByDescendingTotalScoreWithPageNumber:(self.currentUserCount/kPageCountForLandingPages)
//                                                                      pageSize:kPageCountForLandingPages
//                                                                   classString:[self.currentFilterYearDictionary objectForKey:@"name"]
//                                                            conferenceIdString:[self.currentFilterConference.identifier stringValue]
//                                                                  successBlock:^{
//                                                                      self.currentUserCount += kPageCountForLandingPages;
//                                                                      self.dataDownloadInProgress = NO;
//                                                                      [self loadData];
//                                                                  } failureBlock:^{
//                                                                      self.dataDownloadInProgress = NO;
//                                                                      NSLog(@"Data downloading failed in :%@",[self class]);
//                                                                  }];
}

- (void)searchFilteredData
{
    if (self.searchBar.text.length < 3) {
        self.pagingEndReached = NO;
        [self checkServer];
    }
    else {
        [self showProgressHudInView:self.view withText:@"Loading"];
        self.dataIsFiltered = YES;
        
        [SDLandingPagesService searchForTeamsWithNameString:self.searchBar.text successBlock:^{
            [self loadFilteredData];
        } failureBlock:^{
            
        }];
        
//        [SDLandingPagesService searchForTeamsWithNameString:self.searchBar.text conferenceIDString:[self.currentFilterConference.identifier stringValue] classString:[self.currentFilterYearDictionary objectForKey:@"name"] successBlock:^{
//            [self loadFilteredData];
//        } failureBlock:^{
//            NSLog(@"Search failed in Collenge landing page");
//        }];
    }
}


#pragma mark - Data Fetching

- (void)loadData
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeTeam];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    //seting fetch limit for pagination
    NSFetchRequest *request = [User MR_requestAllWithPredicate:predicate inContext:context];
    
    // ? ?? ?
//    [request setFetchLimit:self.currentUserCount];
    //set sort descriptor
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theTeam.totalScore" ascending:NO];
//    NSSortDescriptor *commitsDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theTeam.numberOfCommits" ascending:NO];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:nameDescriptor,nil]];
    self.dataArray = [User MR_executeFetchRequest:request inContext:context];

    // ? ? ? ?
//    if ([self.dataArray count] < self.currentCollegeCount) {
//        self.pagingEndReached = YES;
//    }
    
    [self hideProgressHudInView:self.view];
    [self reloadTableView];
}

- (void)loadFilteredData
{
    NSPredicate *userTypePredicate = [NSPredicate predicateWithFormat:@"userTypeId == %d",SDUserTypeTeam];
    //    NSPredicate *userYearPredicate = [NSPredicate predicateWithFormat:@"theTeam.teamClass == %@",[self.currentFilterYearDictionary valueForKey:@"name"]];
    NSPredicate *nameSearchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", self.searchBar.text];
    
    //also add self.currentFilterState.code and [self.currentFilterPositionDictionary objectForKey:@"shortName"]
    NSPredicate *compoundPredicate = (self.searchBar.text.length > 0) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate,nameSearchPredicate]] : [NSCompoundPredicate andPredicateWithSubpredicates:@[userTypePredicate]];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dataArray = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:compoundPredicate inContext:context];
    
    [self reloadTableView];
    [self hideProgressHudInView:self.view];
}


@end
