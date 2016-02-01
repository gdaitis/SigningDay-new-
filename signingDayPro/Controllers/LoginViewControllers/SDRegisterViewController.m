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
#import "SDLoginService.h"
#import "SDStandartNavigationController.h"
#import "SDThankYouViewController.h"

#define kSDRegisterViewControllerParentsStuffViewInsertionYCoordinate 340

@interface SDRegisterViewController ()

@property (nonatomic, strong) UITextField *signInNameTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *birthdayTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *firstPasswordTextField;
@property (nonatomic, strong) UITextField *secondPasswordTextField;
@property (nonatomic, strong) UITextField *parentEmailTextField;
@property (nonatomic, strong) UIView *parentsStuffView;
@property (assign) BOOL needsParentConsent;

@end

@implementation SDRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [(SDStandartNavigationController *)self.navigationController setNavigationTitle:@"Register Account"];
    
    self.needsParentConsent = NO;
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
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
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
                                                                   infoText:@"Your password must be at least 6 characters long"
                                                          forFirstTextField:&newPasswordTextField
                                                            secondTextField:&confirmPasswordTextField];
    self.firstPasswordTextField = newPasswordTextField;
    self.firstPasswordTextField.secureTextEntry = YES;
    self.secondPasswordTextField = confirmPasswordTextField;
    self.secondPasswordTextField.secureTextEntry = YES;
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

- (void)joinNowSelected
{
    if (!self.signInNameTextField.text) {
        [self showAlertWithTitle:nil
                         andText:@"Please enter sign in name"];
        return;
    } else if (self.signInNameTextField.text.length < 3) {
        [self showAlertWithTitle:nil
                         andText:@"Your sign in name must be at least 3 characters long"];
        return;
    } else if (self.signInNameTextField.text.length > 64) {
        [self showAlertWithTitle:nil
                         andText:@"Your sign in name must be less than 64 characters long"];
        return;
    } else if (![self validateUsernamelWithString:self.signInNameTextField.text]) {
        [self showAlertWithTitle:nil
                         andText:@"You can only use alphabetical letters, numbers and characters like _ - @ . in username field"];
        return;
    } else if (!self.emailTextField.text) {
        [self showAlertWithTitle:nil
                         andText:@"Please enter email"];
        return;
    } else if (![self validateEmailWithString:self.emailTextField.text]) {
        [self showAlertWithTitle:nil
                         andText:@"Your email is not correct"];
        return;
    } else if (!self.birthdayTextField.text) {
        [self showAlertWithTitle:nil
                         andText:@"Please enter your birthday"];
        return;
    } else if (!self.firstPasswordTextField.text) {
        [self showAlertWithTitle:nil
                         andText:@"Please enter password"];
        return;
    } else if (self.firstPasswordTextField.text.length < 6) {
        [self showAlertWithTitle:nil
                         andText:@"Your password must be at least 6 characters long"];
        return;
    } else if (!self.secondPasswordTextField.text) {
        [self showAlertWithTitle:nil
                         andText:@"Please confirm the password"];
        return;
    } else if (![self.firstPasswordTextField.text isEqual:self.secondPasswordTextField.text]) {
        [self showAlertWithTitle:nil
                         andText:@"Password confirmation is not correct"];
        return;
    } else if (!self.checkboxButton.selected) {
        [self showAlertWithTitle:nil
                         andText:@"You must accept the Terms and Conditions and Privacy Policy"];
        return;
    }
    
    if (self.needsParentConsent) {
        if (!self.parentCheckboxButton.selected) {
            [self showAlertWithTitle:nil
                             andText:@"You must have parents permision to proceed"];
            return;
        } else if (!self.parentEmailTextField.text) {
            [self showAlertWithTitle:nil
                             andText:@"Please enter parent email"];
            return;
        } else if (![self validateEmailWithString:self.parentEmailTextField.text]) {
            [self showAlertWithTitle:nil
                             andText:@"Your parent email is not correct"];
            return;
        }
    }
    
    [self beginRefreshing];
    
    [SDLoginService registerNewUserWithType:self.userType
                                   username:self.signInNameTextField.text
                                   password:self.firstPasswordTextField.text
                                      email:self.emailTextField.text
                                parentEmail:self.parentEmailTextField.text
                             birthdayString:self.birthdayTextField.text
                              parentConsent:YES
                               successBlock:^{
                                   [self endRefreshing];
                                   
                                   SDThankYouViewController *thankYouController = [[SDThankYouViewController alloc] init];
                                   thankYouController.infoText = @"Your SigningDay account has been created.";
                                   thankYouController.buttonText = @"RETURN TO LOGIN";
                                   [self.navigationController pushViewController:thankYouController animated:YES];
                               } failureBlock:^{
                                   [self endRefreshing];
                                   
                                   [self showAlertWithTitle:nil
                                                    andText:@"The username you entered already exists"];
                               }];
}

- (void)datePicked
{
    NSDate *date = [self.datePicker date];
    NSString *dateString = [SDUtils formatedDateWithoutHoursStringFromDate:date];
    self.birthdayTextField.text = dateString;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    int years = [components year];
    
    if (years < 13) {
        if (!self.needsParentConsent) {
            [self expandViewWithParentsConsent];
            self.needsParentConsent = YES;
        }
    } else {
        [self removeParentsConsent];
        self.needsParentConsent = NO;
    }
}

- (void)expandViewWithParentsConsent
{
    CGFloat currentY = kSDRegisterViewControllerParentsStuffViewInsertionYCoordinate;
    
    self.parentsStuffView = [[UIView alloc] init];
    UIView *parentsChecboxView = [self parentCheckboxViewAtYPoint:0];
    UITextField *parentEmailTextField;
    UIView *parentsEmailView = [self inputFieldAtYPoint:parentsChecboxView.frame.size.height + 15
                                    withPlaceholderText:@"Parent Email Address"
                                               infoText:@"Your e-mail address will not be published"
                                           forTextField:&parentEmailTextField];
    parentEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.parentEmailTextField = parentEmailTextField;
    [self.parentsStuffView addSubview:parentsChecboxView];
    [self.parentsStuffView addSubview:parentsEmailView];
    self.parentsStuffView.frame = CGRectMake(0,
                                             currentY,
                                             self.view.frame.size.width,
                                             parentsEmailView.frame.origin.y + parentsEmailView.frame.size.height + 18);
    
    for (UIView *subview in self.contentView.subviews) {
        if (subview.frame.origin.y >= currentY) {
            CGRect subviewFrame = subview.frame;
            subviewFrame.origin.y += self.parentsStuffView.frame.size.height;
            subview.frame = subviewFrame;
        }
    }
    [self.contentView addSubview:self.parentsStuffView];
    CGRect contentViewFrame = self.contentView.frame;
    contentViewFrame.size.height += self.parentsStuffView.frame.size.height;
    self.contentView.frame = contentViewFrame;
    
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)removeParentsConsent
{
    [self.parentsStuffView removeFromSuperview];
    
    for (UIView *subview in self.contentView.subviews) {
        if (subview.frame.origin.y >= kSDRegisterViewControllerParentsStuffViewInsertionYCoordinate) {
            CGRect subviewFrame = subview.frame;
            subviewFrame.origin.y -= self.parentsStuffView.frame.size.height;
            subview.frame = subviewFrame;
        }
    }
    CGRect contentViewFrame = self.contentView.frame;
    contentViewFrame.size.height -= self.parentsStuffView.frame.size.height;
    self.contentView.frame = contentViewFrame;
    
    self.scrollView.contentSize = self.contentView.frame.size;
}

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
    SDTermsViewController *termsViewController = [storyboard instantiateViewControllerWithIdentifier:@"TermsStroyBoardID"];
    if ([[url description] isEqual:kSDCommonRegistrationViewControllerTermsAndConditionsLink]) {
        termsViewController.urlString = @"/p/terms.aspx";
        termsViewController.navigationTitle = @"Terms and Conditions";
    } else if ([[url description] isEqual:kSDCommonRegistrationViewControllerPrivacyPolicyLink]) {
        termsViewController.urlString = @"/p/privacy.aspx";
        termsViewController.navigationTitle = @"Privacy Policy";
    }
    [self.navigationController pushViewController:termsViewController
                                         animated:YES];
}

@end
