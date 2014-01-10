//
//  SDClaimRegistrationViewController.m
//  SigningDay
//
//  Created by lite on 07/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDClaimRegistrationViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SDStandartNavigationController.h"
#import "SDLoginService.h"
#import "User.h"

@interface SDClaimRegistrationViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *capturedImage;

@end

@implementation SDClaimRegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [(SDStandartNavigationController *)self.navigationController setNavigationTitle:@"Claim Account"];
}

- (UIView *)createContentView
{
    UIView *contentView = [[UIView alloc] init];
    
    CGFloat currentY = 0;
    
    UIView *topView = [self topViewWithActivationNotificationLabelAtYPoint:currentY];
    [contentView addSubview:topView];
    
    currentY += topView.frame.size.height + 16;
    UITextField *emailTextField;
    UIView *emailFieldView = [self inputFieldAtYPoint:currentY
                                  withPlaceholderText:@"Email Address"
                                             infoText:@"Your e-mail address will not be published"
                                         forTextField:&emailTextField];
    self.emailTextField = emailTextField;
    [contentView addSubview:emailFieldView];
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    currentY += emailFieldView.frame.size.height + 13;
    UITextField *phoneTextField;
    UIView *phoneFieldView = [self inputFieldAtYPoint:currentY
                                  withPlaceholderText:@"Phone"
                                             infoText:nil
                                         forTextField:&phoneTextField];
    self.phoneTextField = phoneTextField;
    [contentView addSubview:phoneFieldView];
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    currentY += phoneFieldView.frame.size.height + 22;
    UIView *photoButtonView = [self uploadButtonViewAtYPoint:currentY
                                                withSelector:@selector(uploadPhotoSelected)
                                                      target:self];
    [contentView addSubview:photoButtonView];
    
    currentY += photoButtonView.frame.size.height + 5;
    UIView *noticeView = [self viewForNoticeLabelAtYPoint:currentY];
    [contentView addSubview:noticeView];
    
    currentY += noticeView.frame.size.height + 20;
    UIView *claimAccountButtonView = [self greenButtonViewAtYPoint:currentY
                                                         withTitle:@"Claim Account"
                                                          selector:@selector(claimAccountSelected)];
    [contentView addSubview:claimAccountButtonView];
    
    currentY += claimAccountButtonView.frame.size.height + 66;
    contentView.frame = CGRectMake(0,
                                   0,
                                   self.view.frame.size.width,
                                   currentY);
    
    return contentView;
}

- (void)uploadPhotoSelected
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose source"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Library", nil];
    [actionSheet showInView:self.view];
}

- (void)claimAccountSelected
{
    
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2)
        return;
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.wantsFullScreenLayout = YES;
    self.imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    if (buttonIndex == 0) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    } else if (buttonIndex == 1) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self.navigationController presentViewController:self.imagePicker
                                            animated:YES
                                          completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.capturedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (self.capturedImage && picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageView *snapshot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
        snapshot.image = self.capturedImage;
        snapshot.transform = picker.cameraViewTransform;
        picker.cameraOverlayView = snapshot;
    }
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    if ([[url description] isEqual:kSDCommonRegistrationViewControllerTwitterLink]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=Signing_Day"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/Signing_Day"]];
        }
    }
}

@end
