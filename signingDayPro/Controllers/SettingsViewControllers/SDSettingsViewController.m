//
//  SDSettingsViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SDSettingsViewController.h"
#import "SDNavigationController.h"
#import "SDAppDelegate.h"
#import "SDSimplifiedCameraOverlayView.h"
#import "SDProfileService.h"
#import "Master.h"
#import "User.h"
#import "SDAPIClient.h"
#import "SDLoginService.h"
#import "MBProgressHUD.h"
#import "SDTermsViewController.h"

@interface SDSettingsViewController () <UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SDCameraOverlayViewDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *capturedImage;
//@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation SDSettingsViewController

@synthesize imagePicker = _imagePicker;
@synthesize capturedImage = _capturedImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.refreshControl removeFromSuperview];
    
    self.tableView.backgroundColor = kBaseBackgroundColor;
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)signOutButtonPressed
{
    [SDLoginService logout];
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCellID";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
    }
    
    //rounding selected cell corners
    cell.selectedBackgroundView = nil;
    UIView *cellSelectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 300, cell.frame.size.height)];
    cellSelectedBackgroundView.backgroundColor = kBaseSelectedCellColor;
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    
    BOOL osOlderThan7 = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? NO : YES;
    
    //first section text
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
                cell.textLabel.text = @"Edit profile";
            if (osOlderThan7)
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:cellSelectedBackgroundView.frame byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){8, 8}].CGPath;
        }
        else {
            cell.textLabel.text = @"Sharing settings";
            if (osOlderThan7)
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:cellSelectedBackgroundView.frame byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){8, 8}].CGPath;
        }
    }//second section text
    else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Terms of service";
            if (osOlderThan7)
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:cellSelectedBackgroundView.frame byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){8, 8}].CGPath;
        }
        else {
            cell.textLabel.text = @"Privacy Policy";
            if (osOlderThan7)
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:cellSelectedBackgroundView.frame byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){8, 8}].CGPath;
        }
    }
    
    
    //assigning selected rounded view to cell
    if (osOlderThan7)
    cellSelectedBackgroundView.layer.mask = maskLayer;
    
    cell.selectedBackgroundView = cellSelectedBackgroundView;
    
    return cell;
}

#pragma mark UITableView delegate mothods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = @"About";
    if (section == 0) {
        sectionTitle = @"Account";
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 3, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1];
    //label.shadowColor = [UIColor colorWithRed:169.0/255.0 green:169.0/255.0 blue:169.0/255.0 alpha:1];
    //label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view addSubview:label];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //adding signout button in first tableview sections footer
    
    if (section == 0) {
        
        //creating result view
        UIImage *signOutImage = [UIImage imageNamed:@"sign_out_button.png"];
        UIView *result = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        result.backgroundColor = [UIColor clearColor];
        
        //adding signout button
        CGRect frame = CGRectMake((self.view.frame.size.width/2) - (signOutImage.size.width/2), 10, signOutImage.size.width, signOutImage.size.height);
        UIButton *abutton = [[UIButton alloc] initWithFrame:frame];
        [abutton setBackgroundImage:signOutImage forState:UIControlStateNormal];
        [abutton addTarget:self action:@selector(signOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [result addSubview:abutton];
        
        return result;
    }
    else {
        
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
    UIViewController *viewController = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"EditProfileStoryBoardID"];
        }
        else {
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"SharingSettingsStoryBoardID"];
        }
    }
    else {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"TermsStroyBoardID"];
        
        if (indexPath.row == 0) {
            ((SDTermsViewController *)viewController).urlString = @"/p/terms.aspx";
        }
        else {
            ((SDTermsViewController *)viewController).urlString = @"/p/privacy.aspx";
        }
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101 || actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            // remove pic
            [SDProfileService deleteAvatar];
        } else if (buttonIndex == 1) {
            // take pic
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose source"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Camera", @"Library", nil];
            actionSheet.tag = 103;
            [actionSheet showInView:self.view];
        } else if (actionSheet.tag == 101) {
            if (buttonIndex == 2) {
                // facebook
                NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                
                NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
                
                SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
                    appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
                }
                [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                    NSLog(@"FB access token: %@", appDelegate.fbSession.accessTokenData.accessToken);
                    if (status == FBSessionStateOpen) {
                        master.facebookSharingOn = [NSNumber numberWithBool:YES];
                        [context MR_saveToPersistentStoreAndWait];
                    }
                }];
                
                [SDProfileService getAvatarImageFromFacebookAndSendItToServerForUserIdentifier:master.identifier completionHandler:^{
                    NSLog(@"Avatar from Facebook uploaded sucessfully");
                }];
            }
        }
    } else if (actionSheet.tag == 103) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.wantsFullScreenLayout = YES;
        if (buttonIndex == 0) {
            // Camera
            //            self.isFromLibrary = NO;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            self.imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.23, 1.23);
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            self.imagePicker.showsCameraControls = NO;
            SDSimplifiedCameraOverlayView *cameraOverlayView = [[SDSimplifiedCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
            cameraOverlayView.delegate = self;
            self.imagePicker.cameraOverlayView = cameraOverlayView;
        } else if (buttonIndex == 1) {
            // Library
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        }
        if (buttonIndex != 2)
        [self presentViewController:self.imagePicker animated:YES completion:^{
            
        }];
    } else if (actionSheet.tag == 104) {
        if (buttonIndex == 0) {
            // send image to server
            Master *master = [self getMaster];
            [SDProfileService uploadAvatar:self.capturedImage forUserIdentifier:master.identifier completionBlock:^{
                NSLog(@"Avatar updates successfully");
            }];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.capturedImage = image;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send", nil];
    actionSheet.tag = 104;
    [actionSheet showInView:self.imagePicker.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - SDCameraOverlayView delegate methods

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

- (void)cameraOverlayView:(SDCameraOverlayView *)view didChangeCamera:(BOOL)toPortrait
{
    if (toPortrait)
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    else
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
}

- (void)cameraOverlayViewDidCancel:(SDCameraOverlayView *)view
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end









