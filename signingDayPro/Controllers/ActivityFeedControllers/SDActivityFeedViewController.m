//
//  SDActivityFeedViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 6/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedViewController.h"
#import "SDActivityFeedCell.h"
#import "SDActivityFeedButtonView.h"
#import "ActivityStory.h"
#import "SDActivityFeedService.h"
#import "SDUtils.h"
#import "User.h"
#import "SDActivityFeedCellContentView.h"
#import "SDAPIClient.h"
#import "SDImageService.h"
#import "AFNetworking.h"
#import "SDActivityFeedHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "SDEnterMediaInfoViewController.h"
#import "SDPublishPhotoTableViewController.h"
#import "SDPublishVideoTableViewController.h"
#import "SDModalNavigationController.h"
#import "SDActivityFeedTableView.h"
#import "SDBuzzSomethingViewController.h"
#import "SDCommentsViewController.h"
#import "WebPreview.h"
#import "SDActivityStoryViewController.h"
#import "SDGlobalSearchViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "SDImageEnlargementView.h"
#import "SDYoutubePlayerViewController.h"

#import "SDGoogleAnalyticsService.h"

#define kButtonImageViewTag 999
#define kButtonCommentLabelTag 998

@interface SDActivityFeedViewController () <SDActivityFeedHeaderViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SDPublishVideoTableViewControllerDelegate, SDPublishPhotoTableViewControllerDelegate, SDModalNavigationControllerDelegate, SDActivityFeedTableViewDelegate, SDGlobalSearchViewControllerDelegate>

@property (nonatomic, weak) IBOutlet SDActivityFeedTableView *tableView;
@property (nonatomic, weak) IBOutlet SDActivityFeedHeaderView *headerView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property BOOL isFromLibrary;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) NSURL *capturedVideoURL;
@property (nonatomic, strong) NSString *mediaType;

@end

@implementation SDActivityFeedViewController

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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    self.headerView.clipsToBounds = NO;
    
    // Add shadow
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    float y = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        y = 20;
    newShadow.frame = CGRectMake(0, 84 + y, 320, 4);
    newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
    
    [self.view.layer addSublayer:newShadow];
    
    self.tableView.activityStoryCount = 0;
    self.tableView.fetchLimit = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    self.tableView.tableDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearch:) name:kSearchButtonPressedNotification object:nil];
    [((SDNavigationController *)self.navigationController) addSearchButton];
    
    [self.tableView checkServerAndDeleteOld:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSearchButtonPressedNotification object:nil];
    [((SDNavigationController *)self.navigationController) removeSearchButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Activity Feed screen";
    [self.tableView loadData];
    
#warning DEBUG
    //---
    SDGlobalSearchViewController *globalSearchViewController = [[SDGlobalSearchViewController alloc] init];
    [self addChildViewController:globalSearchViewController];
    [self.view addSubview:globalSearchViewController.view];
    globalSearchViewController.view.frame = CGRectMake(0,
                                                       64,
                                                       self.view.frame.size.width,
                                                       200);
    globalSearchViewController.delegate = self;
    [globalSearchViewController didMoveToParentViewController:self];
    //---
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkServer
{
    self.tableView.activityStoryCount = 0;
    self.tableView.fetchLimit = 0;
    self.tableView.lastActivityStoryDate = nil;
    self.tableView.endReached = NO;
    [self.tableView checkServerAndDeleteOld:YES];
}

#pragma mark - SDActivityFeedTableView delegate methods

- (void)activityFeedTableView:(SDActivityFeedTableView *)activityFeedTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withActivityStory:(ActivityStory *)activityStory
{
    if (activityStory.webPreview) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:activityStory.webPreview.link]];
    }
    else {
        if (activityStory.mediaType) {
            if ([activityStory.mediaType isEqualToString:@"photos"]) {
                //photos
                //show enlarged image view
                [self showImageViewWithActivityStory:activityStory];
            }
            else {
                //videos
                [self playVideoWithActivityStory:activityStory];
            }
        }
    }
}

- (void)showImageViewWithActivityStory:(ActivityStory *)activityStory
{
    SDImageEnlargementView *imageEnlargemenetView = [[SDImageEnlargementView alloc] initWithFrame:self.view.frame andImage:activityStory.mediaUrl];
    [imageEnlargemenetView presentImageViewInView:self.navigationController.view];
}

- (void)activityFeedTableViewShouldEndRefreshing:(SDActivityFeedTableView *)activityFeedTableView
{
    [self endRefreshing];
}

- (void)activityFeedTableView:(SDActivityFeedTableView *)activityFeedTableView
    wantsNavigateToController:(UIViewController *)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - SDActivityFeedHeaderViewDelegate methods

- (void)activityFeedHeaderViewDidClickOnAddMedia:(SDActivityFeedHeaderView *)activityFeedHeaderView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose source"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Library", nil];
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
    [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Post_Photo/Video_Selected_Activity_Feed"];
}

- (void)activityFeedHeaderViewDidClickOnBuzzSomething:(SDActivityFeedHeaderView *)activityFeedHeaderView
{
    SDModalNavigationController *modalNavigationViewController = [[SDModalNavigationController alloc] init];
    modalNavigationViewController.myDelegate = self;
    SDBuzzSomethingViewController *buzzSomethingViewController = [[UIStoryboard storyboardWithName:@"ActivityFeedStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"BuzzSomethingViewController"];
    [modalNavigationViewController addChildViewController:buzzSomethingViewController];
    [self presentViewController:modalNavigationViewController
                       animated:YES
                     completion:nil];
    [[SDGoogleAnalyticsService sharedService] trackUXEventWithLabel:@"Say_Something_Selected_Activity_Feed"];
}

#pragma mark - Search methods

- (void)showSearch:(NSNotification *)notification
{
    
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101) {
        if (buttonIndex == 2)
            return;
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.wantsFullScreenLayout = YES;
        [[Reachability reachabilityForInternetConnection] startNotifier];
        NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if (buttonIndex == 0) {
            self.isFromLibrary = NO;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            if (internetStatus == ReachableViaWiFi) {
                self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            } else {
                self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
            }
        } else if (buttonIndex == 1) {
            self.isFromLibrary = YES;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        [self.navigationController presentViewController:self.imagePicker
                                                animated:YES
                                              completion:^{
                                                  if (internetStatus != ReachableViaWiFi) {
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wi-Fi not enabled"
                                                                                                      message:@"In order to share videos, Wi-Fi connection needs to be established. Videos captured without a Wi-Fi connection can be saved to library"
                                                                                                     delegate:nil
                                                                                            cancelButtonTitle:@"Ok"
                                                                                            otherButtonTitles:nil];
                                                      [alert show];
                                                  }
                                              }];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } else if (actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            SDModalNavigationController *modalNavigationController;
            if ([self.mediaType isEqual:@"public.image"]) {
                SDModalNavigationController *publishPhotoModalNavigationViewController = [[UIStoryboard storyboardWithName:@"ActivityFeedStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PublishPhotoModalNavigationViewController"];
                modalNavigationController = publishPhotoModalNavigationViewController;
            } else if ([self.mediaType isEqual:@"public.movie"]) {
                SDModalNavigationController *publishVideoModalNavigationViewController = [[UIStoryboard storyboardWithName:@"ActivityFeedStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PublishVideoModalNavigationViewController"];
                modalNavigationController = publishVideoModalNavigationViewController;
            }
            modalNavigationController.myDelegate = self;
            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:^{
                                                              [self presentViewController:modalNavigationController
                                                                                 animated:YES
                                                                               completion:nil];
                                                          }];
            
        } else if (buttonIndex == 1 && !self.isFromLibrary) {
            if ([self.mediaType isEqual:@"public.movie"])
                UISaveVideoAtPathToSavedPhotosAlbum([self.capturedVideoURL path], nil, nil, nil);
            else if ([self.mediaType isEqual:@"public.image"])
                UIImageWriteToSavedPhotosAlbum(self.capturedImage, nil, nil, nil);
            
            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:nil];
        } else if (buttonIndex == 2 && !self.isFromLibrary) {
            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:nil];
        }
    } else if (actionSheet.tag == 103) {
        if (buttonIndex == 0 && !self.isFromLibrary) {
            if ([self.mediaType isEqual:@"public.movie"])
                UISaveVideoAtPathToSavedPhotosAlbum([self.capturedVideoURL path], nil, nil, nil);
            else if ([self.mediaType isEqual:@"public.image"])
                UIImageWriteToSavedPhotosAlbum(self.capturedImage, nil, nil, nil);
        }
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:nil];
    }
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *snapshotImage = nil;
    self.mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([self.mediaType isEqual:@"public.movie"]) {
        
        NSURL *videoURL= [info objectForKey:UIImagePickerControllerMediaURL];
        self.capturedVideoURL = videoURL;
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        snapshotImage = [[UIImage alloc] initWithCGImage:image];
        
        CGImageRelease(image);
        
        
        [self showActionSheet];
        
        
    } else if ([self.mediaType isEqual:@"public.image"]) {
        snapshotImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        self.capturedImage = snapshotImage;
        
        [self showActionSheet];
    }
    
    if (snapshotImage && picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageView *snapshot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
        snapshot.image = snapshotImage;
        snapshot.transform = picker.cameraViewTransform;
        picker.cameraOverlayView = snapshot;
    }
}

- (void)showActionSheet
{
    UIActionSheet *actionSheet;
    if (!self.isFromLibrary) {
        [[Reachability reachabilityForInternetConnection] startNotifier];
        NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        
        if ((internetStatus != ReachableViaWiFi) && [self.mediaType isEqual:@"public.movie"]) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Library", nil];
            actionSheet.tag = 103;
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", @"Save to Library", nil];
            actionSheet.tag = 102;
        }
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil];
        actionSheet.tag = 102;
    }
    
    [actionSheet showInView:self.imagePicker.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - SDPublishVideoTableViewControllerDelegate delegate methods

- (NSURL *)urlOfVideo
{
    return self.capturedVideoURL;
}

#pragma mark - SDPublishPhotoTableViewControllerDelegate delegate methods

- (UIImage *)capturedImageFromDelegate
{
    return self.capturedImage;
}

#pragma mark - SDModalNavigationController myDelegate methods

- (void)modalNavigationControllerWantsToClose:(SDModalNavigationController *)modalNavigationController
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self checkServer];
                             }];
}

#pragma mark - UINavigationController delegate methods

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
