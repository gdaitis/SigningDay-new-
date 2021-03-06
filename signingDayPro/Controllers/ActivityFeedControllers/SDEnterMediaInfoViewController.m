//
//  SDEnterMediaInfoViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDEnterMediaInfoViewController.h"
#import "SDModalNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "Master.h"
#import "SDAppDelegate.h"
#import "SDAddTagsViewController.h"
#import "User.h"
#import <Twitter/Twitter.h>

@interface SDEnterMediaInfoViewController () <SDAddTagsViewControllerDelegate, SDModalNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (nonatomic, strong) NSArray *tagUsersArray;

- (CGFloat)getHeightOfTagsTextLabel;

@end

@implementation SDEnterMediaInfoViewController

@synthesize titleTextView = _titleTextView;
@synthesize descriptionTextView = _descriptionTextView;
@synthesize facebookSwitch = _facebookSwitch;
@synthesize twitterSwitch = _twitterSwitch;
@synthesize facebookConfigureLabel = _facebookConfigureLabel;
@synthesize twitterConfigureLabel = _twitterConfigureLabel;
@synthesize tagsLabel = _tagsLabel;
@synthesize tagsArray = _tagsArray;
@synthesize tagUsersArray = _tagUsersArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = [UIImage imageNamed:@"MenuButtonClose.png"];
    [btn addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.titleTextView.placeholder = @"Title";
    self.titleTextView.placeholderColor = [UIColor grayColor];
    
    self.descriptionTextView.placeholder = @"Description";
    self.descriptionTextView.placeholderColor = [UIColor grayColor];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1];
    
    self.tagsLabel.textColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)cancelButtonPressed
{    
    SDModalNavigationController *modalNavigationController = (SDModalNavigationController *)self.navigationController;
    [modalNavigationController closePressed];
}

- (void)viewDidUnload
{
    [self setDescriptionTextView:nil];
    [self setTagsLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"presentAddTagsViewController"]) {
        SDModalNavigationController *modalNavigationController = [segue destinationViewController];
        modalNavigationController.myDelegate = self;
    }
}

- (CGFloat)getHeightOfTagsTextLabel
{
    NSString *text;
    if ([self.tagsArray count] == 0)
        text = @"Tags";
    else
        text = [self.tagsArray componentsJoinedByString:@", "];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(221, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}

#pragma mark - UITableView delegate and data source methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 3, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:73.0/255.0 green:72.0/255.0 blue:72.0/255.0 alpha:1];
    label.shadowColor = [UIColor colorWithRed:169.0/255.0 green:169.0/255.0 blue:169.0/255.0 alpha:1];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        
        if (indexPath.row == 0) {
            BOOL facebook = [master.facebookSharingOn boolValue];
            if (!facebook) {
                if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
                    appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
                }
                [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                    NSLog(@"FB access token: %@", appDelegate.fbSession.accessTokenData.accessToken);
                    if (status == FBSessionStateOpen) {
                        master.facebookSharingOn = [NSNumber numberWithBool:YES];
                        
                        [context MR_saveToPersistentStoreAndWait];
                        [self.tableView reloadData];
                        
                        
                    }
                    
                }];
            }
        } else if (indexPath.row == 1) {
            BOOL twitter = [master.twitterSharingOn boolValue];
            if (!twitter) {
                ACAccountStore *store = [[ACAccountStore alloc] init];
                ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                [store requestAccessToAccountsWithType:twitterAccountType
                                               options:nil
                                            completion:^(BOOL granted, NSError *error) {
                                                if (!granted) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                                                                            message:@"There is no permissions granted for SigningDay app to post on your behalf. You can change the permissions in Settings."
                                                                                                           delegate:nil
                                                                                                  cancelButtonTitle:@"Ok"
                                                                                                  otherButtonTitles:nil];
                                                        [alertView show];
                                                    });
                                                } else {
                                                    NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                                    if ([twitterAccounts count] > 0) {
                                                        ACAccount *account = [twitterAccounts objectAtIndex:0];
                                                        appDelegate.twitterAccount = account;
                                                        master.twitterSharingOn = [NSNumber numberWithBool:YES];
                                                        [context MR_saveToPersistentStoreAndWait];
                                                    } else {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                                                                message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                                                                               delegate:nil
                                                                                                      cancelButtonTitle:@"Ok"
                                                                                                      otherButtonTitles:nil];
                                                            [alertView show];
                                                        });
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.tableView reloadData];
                                                    });
                                                }
                                            }];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *text;
            if ([self.tagsArray count] == 0)
                text = @"Tags";
            else
                text = [self.tagsArray componentsJoinedByString:@", "];
            self.tagsLabel.text = text;
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            self.facebookConfigureLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 11, 72, 21)];
            self.facebookConfigureLabel.text = @"enable";
            self.facebookConfigureLabel.textColor = [UIColor darkGrayColor];
            self.facebookConfigureLabel.backgroundColor = [UIColor clearColor];

            self.facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            
            cell.textLabel.text = @"Facebook";
            
            BOOL facebook = [master.facebookSharingOn boolValue];
            if (facebook) {
                cell.accessoryView = self.facebookSwitch;
            } else {
                cell.accessoryView = self.facebookConfigureLabel;
            }
            
        } else if (indexPath.row == 1) {
            self.twitterConfigureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 72, 21)];
            NSString *twitterConfigureLabelText;
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
            if ([twitterAccounts count] > 0)
                twitterConfigureLabelText = @"enable";
            else
                twitterConfigureLabelText = @"no twitter account";
            CGSize size = [twitterConfigureLabelText sizeWithFont:self.twitterConfigureLabel.font];
            CGRect frame = self.twitterConfigureLabel.frame;
            frame.size.width = size.width;
            self.twitterConfigureLabel.frame = frame;
            self.twitterConfigureLabel.text = twitterConfigureLabelText;
            self.twitterConfigureLabel.textColor = [UIColor darkGrayColor];
            self.twitterConfigureLabel.backgroundColor = [UIColor clearColor];
            
            self.twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

            cell.textLabel.text = @"Twitter";
            
            BOOL twitter = [master.twitterSharingOn boolValue];
            if (twitter) {
                cell.accessoryView = self.twitterSwitch;
            } else {
                cell.accessoryView = self.twitterConfigureLabel;
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 45;
        }
        if (indexPath.row == 1) {
            return 118;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [self getHeightOfTagsTextLabel] + 27;
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            return 45;
        }
        if (indexPath.row == 1) {
            return 45;
        }
    }
    return 0;
}

#pragma mark - SDAddTagsViewController delegate methods

- (void)addTagsViewController:(SDAddTagsViewController *)addTagsViewController
         didFinishPickingTags:(NSArray *)tagUsersArray
{
    self.tagUsersArray = tagUsersArray;
    
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    for (User *user in tagUsersArray) {
        [namesArray addObject:user.name];
    }
    self.tagsArray = namesArray;
    
    if ([tagUsersArray count] == 0)
        self.tagsLabel.textColor = [UIColor grayColor];
    else
        self.tagsLabel.textColor = [UIColor blackColor];
    
    float newHeight = [self getHeightOfTagsTextLabel];
    self.tagsLabel.frame = CGRectMake(self.tagsLabel.frame.origin.x,
                                      self.tagsLabel.frame.origin.y,
                                      self.tagsLabel.frame.size.width,
                                      newHeight);
    
    [self.tableView reloadData];
}

- (NSArray *)arrayOfAlreadySelectedTags
{
    if (!self.tagUsersArray)
        self.tagUsersArray = [[NSArray alloc] init];
    return self.tagUsersArray;
}

@end
