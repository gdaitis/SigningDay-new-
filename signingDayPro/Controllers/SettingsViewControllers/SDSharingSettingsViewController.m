//
//  SDSharingSettingsViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/20/12.
//
//

#import "SDSharingSettingsViewController.h"
#import "SDAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Master.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>

@interface SDSharingSettingsViewController ()

@end

@implementation SDSharingSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundColor = kBaseBackgroundColor;
    
    UIImage *image = [UIImage imageNamed:@"back_nav_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view delegate and data source methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (indexPath.row == 0) { // Facebook
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
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
                    [tableView reloadData];
                    
                }
            }];
        } else {
            [appDelegate.fbSession close];
            
            master.facebookSharingOn = [NSNumber numberWithBool:NO];
            [context MR_saveToPersistentStoreAndWait];
            [tableView reloadData];
            
        }
    } else if (indexPath.row == 1) { // Twitter
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        BOOL twitter = [master.twitterSharingOn boolValue];
        
        if (!twitter) {
            ACAccountStore *store = [[ACAccountStore alloc] init];
            ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [store requestAccessToAccountsWithType:twitterAccountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error) {
                                            if (!granted) {
                                                NSLog(@"User rejected access to the account.");
                                                
                                                master.twitterSharingOn = [NSNumber numberWithBool:NO];
                                                [context MR_saveToPersistentStoreAndWait];
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [tableView reloadData];
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
                                                    [tableView reloadData];
                                                });
                                            }
                                        }];
        } else {
            master.twitterSharingOn = [NSNumber numberWithBool:NO];
            [context MR_saveToPersistentStoreAndWait];
            [tableView reloadData];
            
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SharingSettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    //rounding selected cell corners
    cell.selectedBackgroundView = nil;
    UIView *cellSelectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 300, cell.frame.size.height)];
    cellSelectedBackgroundView.backgroundColor = kBaseSelectedCellColor;
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    
    BOOL osOlderThan7 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? NO : YES;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    
    if (indexPath.row == 0) { // Facebook
        
        // round top corners
        if (osOlderThan7)
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:cellSelectedBackgroundView.frame byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){8, 8}].CGPath;
        
        
        cell.textLabel.text = @"Facebook";
        BOOL facebook = [master.facebookSharingOn boolValue];
        if (facebook)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.row == 1) { // Twitter
        
        //round bottom corners
        if (osOlderThan7)
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:cellSelectedBackgroundView.frame byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){8, 8}].CGPath;

        
        cell.textLabel.text = @"Twitter";
        BOOL twitter = [master.twitterSharingOn boolValue];
        if (twitter)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //assigning selected rounded view to cell
    if (osOlderThan7)
    cellSelectedBackgroundView.layer.mask = maskLayer;
    
    cell.selectedBackgroundView = cellSelectedBackgroundView;
    
    return cell;
}

@end
