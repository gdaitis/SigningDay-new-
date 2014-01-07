//
//  SDRegisterViewController.m
//  SigningDay
//
//  Created by lite on 02/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDRegisterViewController.h"
#import "SDTermsViewController.h"
#import "SDUtils.h"

@interface SDRegisterViewController ()

@property (nonatomic, strong) UITextField *signInNameTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *birthdayTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *firstPasswordTextField;
@property (nonatomic, strong) UITextField *secondPasswordTextField;

@end

@implementation SDRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0,
                                       0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    UIView *contentView = [self createContentView];
    self.scrollView.contentSize = contentView.frame.size;
    [self.scrollView addSubview:contentView];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
}

- (UIView *)createContentView
{
    UIView *contentView = [[UIView alloc] init];
    
    CGFloat currentY = 0;
    
    currentY += kSDCommonRegistrationViewControllerTopPadding;
    UITextField *signInNameTextField;
    UIView *signInFieldView = [self inputFieldAtYPoint:currentY
                                   withPlaceholderText:@"Sign in name"
                                              infoText:nil
                                          forTextField:&signInNameTextField];
    self.signInNameTextField = signInNameTextField;
    [contentView addSubview:signInFieldView];
    
    currentY += signInFieldView.frame.size.height + kSDCommonRegistrationViewControllerInputFieldVerticalSpacing;
    UITextField *emailTextField;
    UIView *emailTextFieldView = [self inputFieldAtYPoint:currentY
                                      withPlaceholderText:@"Email Address"
                                                 infoText:@"Your e-mail address will not be published"
                                             forTextField:&emailTextField];
    self.emailTextField = emailTextField;
    [contentView addSubview:emailTextFieldView];
    
    currentY += emailTextFieldView.frame.size.height + 20;
    UITextField *birthdayTextField;
    UIView *birthdayFieldView = [self inputFieldForBirthdayAtYPoint:currentY
                                                       forTextField:&birthdayTextField];
    self.birthdayTextField = birthdayTextField;
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self
                        action:@selector(datePicked)
              forControlEvents:UIControlEventValueChanged];
    self.birthdayTextField.inputView = self.datePicker;
    [contentView addSubview:birthdayFieldView];
    
    currentY += birthdayFieldView.frame.size.height + 20;
    UITextField *newPasswordTextField;
    UITextField *confirmPasswordTextField;
    UIView *passwordInputFieldsView = [self passwordInputFieldsViewAtYPoint:currentY
                                                       withFirstPlaceholder:@"New Password"
                                                          secondPlaceholder:@"Confirm Password"
                                                                   infoText:@"Your password must be at least 6 characters"
                                                          forFirstTextField:&newPasswordTextField
                                                            secondTextField:&confirmPasswordTextField];
    self.firstPasswordTextField = newPasswordTextField;
    self.secondPasswordTextField = confirmPasswordTextField;
    [contentView addSubview:passwordInputFieldsView];
    
    currentY += passwordInputFieldsView.frame.size.height + 33;
    UIView *checkboxView = [self checkboxViewAtYPoint:currentY];
    [contentView addSubview:checkboxView];
    
    currentY += checkboxView.frame.size.height + 23;
    UIView *joinButtonView = [self greenButtonViewAtYPoint:currentY
                                                 withTitle:@"Join now"
                                                  selector:@selector(joinNowSelected)];
    [contentView addSubview:joinButtonView];
    
    currentY += joinButtonView.frame.size.height + kSDCommonRegistrationViewControllerBottomPadding;
    
    contentView.frame = CGRectMake(0,
                                   0,
                                   self.view.frame.size.width,
                                   currentY);
    
    return contentView;
}

- (void)birthdaySelected
{
    
}

- (void)joinNowSelected
{
    
}

- (void)datePicked
{
    NSDate *date = [self.datePicker date];
    NSString *dateString = [SDUtils formatedDateWithoutHoursStringFromDate:date];
    self.birthdayTextField.text = dateString;
}

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
    SDTermsViewController *termsViewController = [storyboard instantiateViewControllerWithIdentifier:@"TermsStroyBoardID"];
    if ([[url description] isEqual:kSDCommonRegistrationViewControllerTermsAndConditionsLink]) {
        termsViewController.urlString = @"/p/terms.aspx";
    } else if ([[url description] isEqual:kSDCommonRegistrationViewControllerPrivacyPolicyLink]) {
        termsViewController.urlString = @"/p/privacy.aspx";
    }
    [self.navigationController pushViewController:termsViewController
                                         animated:YES];
}

@end
