//
//  SDRegisterViewController.m
//  SigningDay
//
//  Created by lite on 02/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDRegisterViewController.h"

@interface SDRegisterViewController ()

@property (nonatomic, strong) UITextField *signInNameTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) UITextField *newPasswordTextField;
@property (nonatomic, strong) UITextField *confirmPasswordTextField;

@end

@implementation SDRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
    
    currentY += emailTextFieldView.frame.size.height + kSDCommonRegistrationViewControllerInputFieldVerticalSpacing;
    UILabel *birthdayLabel;
    UIView *birthdayButtonView = [self birthdaySelectButtonViewAtYPoint:currentY
                                                           withSelector:@selector(birthdaySelected)
                                                                 target:self
                                                    targetBirthdayLabel:&birthdayLabel];
    self.birthdayLabel = birthdayLabel;
    [contentView addSubview:birthdayButtonView];
    
    currentY += birthdayButtonView.frame.size.height + kSDCommonRegistrationViewControllerInputFieldVerticalSpacing;
    UITextField *newPasswordTextField;
    UITextField *confirmPasswordTextField;
    UIView *passwordInputFieldsView = [self passwordInputFieldsViewAtYPoint:currentY
                                                       withFirstPlaceholder:@"New Password"
                                                          secondPlaceholder:@"Confirm Password"
                                                                   infoText:@"Your password must be at least 6 characters"
                                                          forFirstTextField:&newPasswordTextField
                                                            secondTextField:&confirmPasswordTextField];
    self.newPasswordTextField = newPasswordTextField;
    self.confirmPasswordTextField = confirmPasswordTextField;
    [contentView addSubview:passwordInputFieldsView];
    
    currentY += passwordInputFieldsView.frame.size.height + kSDCommonRegistrationViewControllerInputFieldVerticalSpacing;
    UIView *checkboxView = [self checkboxViewAtYPoint:currentY];
    [contentView addSubview:checkboxView];
    
    currentY += checkboxView.frame.size.height + kSDCommonRegistrationViewControllerInputFieldVerticalSpacing;
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

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    if ([[url description] isEqual:kSDCommonRegistrationViewControllerTermsAndConditionsLink]) {
        
    } else if ([[url description] isEqual:kSDCommonRegistrationViewControllerPrivacyPolicyLink]) {
        
    }
}

@end
