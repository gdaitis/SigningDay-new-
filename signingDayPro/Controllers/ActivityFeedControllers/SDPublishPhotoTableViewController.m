//
//  SDPublishPhotoTableViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/2/12.
//
//

#import "SDPublishPhotoTableViewController.h"
#import "SDModalNavigationController.h"
#import "SDUploadService.h"
#import "Master.h"
#import "SDAppDelegate.h"
#import "SDFollowingService.h"

#import "SDGoogleAnalyticsService.h"

@interface SDPublishPhotoTableViewController ()

@end

@implementation SDPublishPhotoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SDModalNavigationController *modalNavigationController = (SDModalNavigationController *)self.navigationController;
    self.delegate = (id <SDPublishPhotoTableViewControllerDelegate>) modalNavigationController.myDelegate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[SDFollowingService removeFollowing:YES andFollowed:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SDGoogleAnalyticsService sharedService] trackAppViewWithName:@"Publish photo screen"];
}

- (IBAction)publishPhotoPressed:(id)sender
{
    [self.titleTextView resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    
    NSString *title = self.titleTextView.text;
    NSString *description = self.descriptionTextView.text;
    UIImage *image = [self.delegate capturedImageFromDelegate];
    
    if ([title isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter the title" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    } else {
        [SDUploadService uploadPhotoImage:image
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
