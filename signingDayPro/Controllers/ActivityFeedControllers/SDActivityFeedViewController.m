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
#import "SDCameraOverlayView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "SDEnterMediaInfoViewController.h"
#import "SDPublishPhotoTableViewController.h"
#import "SDPublishVideoTableViewController.h"
#import "SDModalNavigationController.h"
#import "SDBuzzSomethingViewController.h"

#define kButtonImageViewTag 999
#define kButtonCommentLabelTag 998

@interface SDActivityFeedViewController () <SDActivityFeedHeaderViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SDCameraOverlayViewDelegate, SDPublishVideoTableViewControllerDelegate, SDPublishPhotoTableViewControllerDelegate, SDModalNavigationControllerDelegate>

//@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) IBOutlet SDActivityFeedHeaderView *headerView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property BOOL isFromLibrary;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) NSURL *capturedVideoURL;
@property (nonatomic, strong) NSString *mediaType;

- (void)checkServer;

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
        
//    UINib *rowCellNib = [UINib nibWithNibName:@"SDActivityFeedCell" bundle:[NSBundle mainBundle]];
//    [self.tableView registerNib:rowCellNib forCellReuseIdentifier:@"ActivityFeedCellId"];
    
    self.headerView.clipsToBounds = NO;
    
    // Add shadow
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    newShadow.frame = CGRectMake(0, 84, 320, 4);
    newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
    
    [self.view.layer addSublayer:newShadow];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self beginRefreshing];
    [self checkServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkServer
{
    [SDActivityFeedService getActivityStoriesForUser:nil withDate:nil withSuccessBlock:^(int resultCount){
                                        
#warning check if solved a crash!
                                        if ([self respondsToSelector:@selector(loadData)]) {
                                            [self loadData];
                                        }
                                        if ([self respondsToSelector:@selector(endRefreshing)]) {
                                            [self endRefreshing];
                                        }
                                    } failureBlock:^{
                                        //
                                    }];
}

#pragma mark - TableView datasource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityStory *activityStory = [_dataArray objectAtIndex:indexPath.row];
    
    int contentHeight = [SDUtils heightForActivityStory:activityStory];
    int result = 123/*buttons images etc..*/ + contentHeight;
    
    return result;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [_dataArray count];
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDActivityFeedCell *cell = nil;
    NSString *cellIdentifier = @"ActivityFeedCellId";
    
    cell = (SDActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Load cell
        NSArray *topLevelObjects = nil;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDActivityFeedCell" owner:nil options:nil];
        // Grab cell reference which was set during nib load:
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[SDActivityFeedCell class]]) {
                cell = currentObject;
                break;
            }
        }
        //[self setupCell:cell];
    } else {
        [cell.thumbnailImageView cancelImageRequestOperation];
    }

    cell.likeButton.tag = indexPath.row;
    cell.commentButton.tag = indexPath.row;
    
    ActivityStory *activityStory = [_dataArray objectAtIndex:indexPath.row];
    
    cell.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likes count]];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.comments count]];
    cell.nameLabel.text =activityStory.author.name;
    [cell.resizableActivityFeedView setActivityStory:activityStory];
    
    if ([activityStory.author.avatarUrl length] > 0) {
        [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:activityStory.author.avatarUrl]];
    }
    
    cell.postDateLabel.text = [SDUtils formatedTimeForDate:activityStory.createdDate];
    cell.yearLabel.text = @"- DE, 2014";
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 6)];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)loadData
{
    self.dataArray = [ActivityStory MR_findAllSortedBy:@"createdDate" ascending:NO inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [self.tableView reloadData];
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
}

- (void)activityFeedHeaderViewDidClickOnBuzzSomething:(SDActivityFeedHeaderView *)activityFeedHeaderView
{
    SDModalNavigationController *buzzSomethingModalNavigationViewController = [[UIStoryboard storyboardWithName:@"ActivityFeedStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"BuzzSomethingModalNavigationController"];
    buzzSomethingModalNavigationViewController.myDelegate = self;
    [self presentViewController:buzzSomethingModalNavigationViewController
                       animated:YES
                     completion:nil];
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
        if (buttonIndex == 0) {
            self.isFromLibrary = NO;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            self.imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.23, 1.23);
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            self.imagePicker.showsCameraControls = NO;
            
            [[Reachability reachabilityForInternetConnection] startNotifier];
            NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
            if (internetStatus == ReachableViaWiFi) {
                self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            } else {
                self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
            }
            
            SDCameraOverlayView *cameraOverlayView = [[SDCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
            cameraOverlayView.delegate = self;
            self.imagePicker.view.frame = cameraOverlayView.frame;
            self.imagePicker.cameraOverlayView = cameraOverlayView;
        } else if (buttonIndex == 1) {
            self.isFromLibrary = YES;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        [self.navigationController presentViewController:self.imagePicker
                                                animated:YES
                                              completion:nil];
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
            SDCameraOverlayView *cameraOverlayView = [[SDCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
            cameraOverlayView.delegate = self;
            self.imagePicker.cameraOverlayView = cameraOverlayView;
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
        if (internetStatus == ReachableViaWiFi) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send", @"Save to Library", nil];
            actionSheet.tag = 102;
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Library", nil];
            actionSheet.tag = 103;
        }
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send", nil];
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

#pragma mark - SDCameraOverlayView delegate methods

- (void)cameraOverlayView:(SDCameraOverlayView *)view didSwitchTo:(BOOL)state
{
    if (!state)
        [self.imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
    else
        [self.imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
}

- (void)cameraOverlayViewDidChangeFlash:(SDCameraOverlayView *)view
{
    switch (self.imagePicker.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            [view.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_on_button.png"] forState:UIControlStateNormal];
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            break;
            
        case UIImagePickerControllerCameraFlashModeOn:
            [view.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off_button.png"] forState:UIControlStateNormal];
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            break;
            
        case UIImagePickerControllerCameraFlashModeOff:
            [view.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_auto_button.png"] forState:UIControlStateNormal];
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            break;
    }
}

- (void)cameraOverlayViewDidTakePicture:(SDCameraOverlayView *)view
{
    [self.imagePicker takePicture];
}

- (void)cameraOverlayViewDidStartCapturing:(SDCameraOverlayView *)view
{
    [self.imagePicker startVideoCapture];
}

- (void)cameraOverlayViewDidStopCapturing:(SDCameraOverlayView *)view
{
    [self.imagePicker stopVideoCapture];
}

- (void)cameraOverlayView:(SDCameraOverlayView *)view didChangeCamera:(BOOL)toPortrait
{
    if (toPortrait)
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    else
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
}

- (void)cameraOverlayViewDidCancel:(SDCameraOverlayView *)view
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - SDModalNavigationController myDelegate methods

- (void)modalNavigationControllerWantsToClose:(SDModalNavigationController *)modalNavigationController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


@end
