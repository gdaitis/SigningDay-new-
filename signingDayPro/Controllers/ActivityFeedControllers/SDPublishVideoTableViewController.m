//
//  SDPublishVideoTableViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/2/12.
//
//

#import "SDPublishVideoTableViewController.h"
#import "Reachability.h"
#import "SDModalNavigationController.h"
#import "SDUploadService.h"
#import "SDGoogleAnalyticsService.h"

@interface SDPublishVideoTableViewController ()

@end

@implementation SDPublishVideoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SDModalNavigationController *modalNavigationController = (SDModalNavigationController *)self.navigationController;
    self.delegate = (id <SDPublishVideoTableViewControllerDelegate>) modalNavigationController.myDelegate;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SDGoogleAnalyticsService sharedService] trackAppViewWithName:@"Publish video screen"];
}

- (IBAction)publishVideoPressed:(id)sender
{
    [self.titleTextView resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];

    NSURL *videoURL = [self.delegate urlOfVideo];
    NSString *title = self.titleTextView.text;
    NSString *description = self.descriptionTextView.text;
    
    if ([title isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter the title" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    } else {
        [SDUploadService uploadVideoWithURL:videoURL
                                  withTitle:title
                                description:description
                                       tags:[self.tagsArray componentsJoinedByString:@","]
                            facebookSharing:self.facebookSwitch.on
                             twitterSharing:self.twitterSwitch.on
                            completionBlock:^{
                                [self cancelButtonPressed];
                            }];
    }
}

@end
