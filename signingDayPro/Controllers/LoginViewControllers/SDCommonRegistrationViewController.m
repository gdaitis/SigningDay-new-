//
//  SDCommonRegistrationViewController.m
//  SigningDay
//
//  Created by lite on 02/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDCommonRegistrationViewController.h"
#import "UIPlaceHolderTextView.h"

NSString * const kSDCommonRegistrationViewControllerTermsAndConditionsLink = @"SDCommonRegistrationViewControllerTermsAndConditionsLink";
NSString * const kSDCommonRegistrationViewControllerPrivacyPolicyLink = @"SDCommonRegistrationViewControllerPrivacyPolicyLink";
NSString * const kSDCommonRegistrationViewControllerTwitterLink = @"kSDCommonRegistrationViewControllerTwitterLink";

@interface SDCommonRegistrationViewController ()

@end

@implementation SDCommonRegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.view.backgroundColor = [UIColor colorWithRed:221.0f/255.0f
                                                green:221.0f/255.0f
                                                 blue:221.0f/255.0f
                                                alpha:1.0f];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.frame = CGRectMake(0,
                                       0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    self.contentView = [self createContentView];
    self.scrollView.contentSize = self.contentView.frame.size;
    [self.scrollView addSubview:self.contentView];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Private methods

- (UIImageView *)createInputFieldImageViewWithImage:(UIImage *)image
                                           atYPoint:(CGFloat)yPoint
{
    UIImageView *inputFieldBackgroundImageView = [[UIImageView alloc] initWithImage:image];
    CGRect inputFieldFrame = inputFieldBackgroundImageView.frame;
    inputFieldFrame.origin = CGPointMake(kSDCommonRegistrationViewControllerLeftPadding,
                                         yPoint);
    inputFieldBackgroundImageView.frame = inputFieldFrame;
    return inputFieldBackgroundImageView;
}

/*
- (UITextField *)createTextFieldForRect:(CGRect)rect
                        withPlaceholder:(NSString *)placeholder
{
    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = [UIColor clearColor];
    textField.font = [UIFont systemFontOfSize:17];
    textField.placeholder = placeholder;
    textField.frame = CGRectMake(kSDCommonRegistrationViewControllerLeftPadding + kSDCommonRegistrationViewControllerInputFieldInnerLeftPadding,
                                 rect.origin.y,
                                 kSDCommonRegistrationViewControllerInputFieldContentWidth,
                                 rect.size.height);
    textField.delegate = self;
    return textField;
}
*/

- (UILabel *)createInfoLabelWithInfoText:(NSString *)infoText
                                 forRect:(CGRect)rect
{
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.text = infoText;
    infoLabel.textColor = [UIColor colorWithRed:165.0f/255.0f
                                          green:165.0f/255.0f
                                           blue:165.0f/255.0f
                                          alpha:1.0f];
    infoLabel.textAlignment = NSTextAlignmentRight;
    CGRect infoLabelFrame = infoLabel.frame;
    CGSize calculatedSize = [infoLabel sizeThatFits:CGSizeMake(kSDCommonRegistrationViewControllerContentWidth,
                                                               CGFLOAT_MAX)];
    infoLabelFrame.size = CGSizeMake(kSDCommonRegistrationViewControllerContentWidth,
                                     calculatedSize.height);
    infoLabelFrame.origin = CGPointMake(kSDCommonRegistrationViewControllerLeftPadding,
                                        rect.origin.y + rect.size.height + kSDCommonRegistrationViewControllerInputFieldBottomPadding);
    infoLabel.frame = infoLabelFrame;
    
    return infoLabel;
}

- (UIView *)inputFieldAtYPoint:(CGFloat)yPoint
           withPlaceholderText:(NSString *)placeholderText
                      infoText:(NSString *)infoText
               backgroundImage:(UIImage *)backgroundImage
                     iconImage:(UIImage *)iconImage
                  forTextField:(UITextField **)targetTextField
{
    UIView *view = [[UIView alloc] init];
    
    UIImageView *inputFieldBackgroundImageView = [self createInputFieldImageViewWithImage:backgroundImage
                                                                                 atYPoint:0];
    [view addSubview:inputFieldBackgroundImageView];
    
    if (iconImage) {
        UIImageView *calendarIconImageView = [[UIImageView alloc] initWithImage:iconImage];
        CGRect calendarIconImageViewFrame = calendarIconImageView.frame;
        calendarIconImageViewFrame.origin = CGPointMake(kSDCommonRegistrationViewControllerLeftPadding + kSDCommonRegistrationViewControllerInputFieldInnerLeftPadding,
                                                        9);
        calendarIconImageView.frame = calendarIconImageViewFrame;
        calendarIconImageView.userInteractionEnabled = NO;
        calendarIconImageView.exclusiveTouch = NO;
        [view addSubview:calendarIconImageView];
    }
    
    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = [UIColor clearColor];
    textField.font = [UIFont systemFontOfSize:17];
    textField.placeholder = placeholderText;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.frame = CGRectMake(kSDCommonRegistrationViewControllerLeftPadding + kSDCommonRegistrationViewControllerInputFieldInnerLeftPadding + (iconImage ? (iconImage.size.width + 10) : 0),
                                 inputFieldBackgroundImageView.frame.origin.y,
                                 kSDCommonRegistrationViewControllerInputFieldContentWidth - (iconImage ? (iconImage.size.width + 10) : 0),
                                 inputFieldBackgroundImageView.frame.size.height);
    textField.delegate = self;
    [view addSubview:textField];
    *targetTextField = textField;
    
    view.frame = CGRectMake(0,
                            yPoint,
                            self.view.frame.size.width,
                            inputFieldBackgroundImageView.frame.size.height);
    
    if (infoText) {
        UILabel *infoLabel = [self createInfoLabelWithInfoText:infoText
                                                       forRect:inputFieldBackgroundImageView.frame];
        
        CGRect viewFrame = view.frame;
        viewFrame.size.height += infoLabel.frame.origin.y - viewFrame.size.height + infoLabel.frame.size.height;
        view.frame = viewFrame;
        
        [view addSubview:infoLabel];
    }
    return view;
}

- (void)checkboxSelected
{
    self.checkboxButton.selected = !self.checkboxButton.selected;
}

- (void)parentCheckboxSelected
{
    self.parentCheckboxButton.selected = !self.parentCheckboxButton.selected;
}

- (UIView *)buttonViewAtYPoint:(CGFloat)yPoint
                  withSelector:(SEL)selector
                        target:(id)target
                          icon:(UIImage *)icon
                     labelText:(NSString *)labelText
                   targetLabel:(UILabel **)targetLabel
{
    UIView *view = [[UIView alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    UIImage *registrationInputFieldBackgroundImage = [UIImage imageNamed:@"RegistrationInputFieldBg"];
    button.frame = CGRectMake(kSDCommonRegistrationViewControllerLeftPadding,
                              0,
                              registrationInputFieldBackgroundImage.size.width,
                              registrationInputFieldBackgroundImage.size.height);
    [button setBackgroundImage:registrationInputFieldBackgroundImage
                      forState:UIControlStateNormal];
    UIImageView *calendarIconImageView = [[UIImageView alloc] initWithImage:icon];
    CGRect calendarIconImageViewFrame = calendarIconImageView.frame;
    calendarIconImageViewFrame.origin = CGPointMake(kSDCommonRegistrationViewControllerInputFieldInnerLeftPadding,
                                                    9);
    calendarIconImageView.frame = calendarIconImageViewFrame;
    calendarIconImageView.userInteractionEnabled = NO;
    calendarIconImageView.exclusiveTouch = NO;
    [button addSubview:calendarIconImageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = labelText;
    label.textColor = [UIColor colorWithRed:102.0f/255.0f
                                      green:102.0f/255.0f
                                       blue:102.0f/255.0f
                                      alpha:1.0f];
    label.font = [UIFont systemFontOfSize:17];
    CGSize calculatedSize = [label sizeThatFits:CGSizeMake(245,
                                                           registrationInputFieldBackgroundImage.size.height)];
    label.frame = CGRectMake(46,
                             0,
                             calculatedSize.width,
                             registrationInputFieldBackgroundImage.size.height);
    label.userInteractionEnabled = NO;
    label.exclusiveTouch = NO;
    [button addSubview:label];
    if (targetLabel)
        *targetLabel = label;
    
    view.frame = CGRectMake(0,
                            yPoint,
                            self.view.frame.size.width,
                            button.frame.size.height);
    [view addSubview:button];
    
    return view;
}

- (UIView *)checkboxViewAtYPoint:(CGFloat)yPoint
           targetAttributedLabel:(TTTAttributedLabel **)targetAttributedLabel
                       labelText:(NSString *)labelText
                    targetButton:(UIButton **)targetButton
                  buttonSelector:(SEL)selector
{
    UIView *view = [[UIView alloc] init];
    
    UIImage *checkedImage = [UIImage imageNamed:@"RegistrationCheckboxChecked"];
    UIImage *uncheckedImage = [UIImage imageNamed:@"RegistrationCheckboxUnchecked"];
    UIButton *checkboxButton;
    checkboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkboxButton setAdjustsImageWhenHighlighted:NO];
    [checkboxButton setImage:checkedImage
                    forState:UIControlStateSelected];
    [checkboxButton setImage:uncheckedImage
                    forState:UIControlStateNormal];
    [checkboxButton addTarget:self
                       action:selector
             forControlEvents:UIControlEventTouchUpInside];
    checkboxButton.frame = CGRectMake(kSDCommonRegistrationViewControllerLeftPadding,
                                      0,
                                      checkedImage.size.width,
                                      checkedImage.size.height);
    [view addSubview:checkboxButton];
    
    if (targetButton)
        *targetButton = checkboxButton;
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] init];
    label.delegate = self;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textColor = [UIColor colorWithRed:102.0f/255.0f
                                      green:102.0f/255.0f
                                       blue:102.0f/255.0f
                                      alpha:1.0f];
    label.font = [UIFont systemFontOfSize:16];
    label.activeLinkAttributes = nil;
    label.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:YES]};
    label.text = labelText; // ALWAYS SET THE TEXT LAST
    
    CGSize calculatedSize = [label sizeThatFits:CGSizeMake(260,
                                                           CGFLOAT_MAX)];
    CGRect labelFrame = label.frame;
    labelFrame.size = calculatedSize;
    labelFrame.origin = CGPointMake(52, 0);
    label.frame = labelFrame;
    
    [view addSubview:label];
    
    if (targetAttributedLabel)
        *targetAttributedLabel = label;
    
    CGFloat maxHeight = label.frame.size.height > self.checkboxButton.frame.size.height ? label.frame.size.height : self.checkboxButton.frame.size.height;
    view.frame = CGRectMake(0,
                            yPoint,
                            self.view.frame.size.width,
                            maxHeight);
    
    return view;
}

#pragma mark - Keyboard methods

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self resizeViewWithOptions:[notification userInfo]];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self resizeViewWithOptions:[notification userInfo]];
}

- (void)resizeViewWithOptions:(NSDictionary *)options
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    CGRect viewFrame = self.scrollView.frame;
    
    CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    viewFrame.size.height =  keyboardFrameEndRelative.origin.y;
    self.scrollView.frame = viewFrame;
    [UIView commitAnimations];
}

#pragma mark - Public methods

- (UIView *)createContentView
{
    return nil;
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = /*@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"*/@"^[!$&*\\-=^`|~#%'\\.\"+/?_{}\\\\a-zA-Z0-9 ]+@[\\-\\.a-zA-Z0-9]+(?:\\.[a-zA-Z0-9]+)+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validateUsernamelWithString:(NSString*)username
{
    NSString *usernameRegex = @"^[a-zA-Z0-9._@-]+$";
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegex];
    return [usernameTest evaluateWithObject:username];
}

#pragma mark - Public view construction methods

- (UIView *)inputFieldAtYPoint:(CGFloat)yPoint
           withPlaceholderText:(NSString *)placeholderText
                      infoText:(NSString *)infoText
                  forTextField:(UITextField **)targetTextField
{
    UIView *view = [self inputFieldAtYPoint:yPoint
                        withPlaceholderText:placeholderText
                                   infoText:infoText
                            backgroundImage:[UIImage imageNamed:@"RegistrationInputFieldBg"]
                                  iconImage:nil
                               forTextField:targetTextField];
    
    return view;
}

- (UIView *)passwordInputFieldsViewAtYPoint:(CGFloat)yPoint
                       withFirstPlaceholder:(NSString *)firstPlaceholder
                          secondPlaceholder:(NSString *)secondPlaceholder
                                   infoText:(NSString *)infoText
                          forFirstTextField:(UITextField **)firstTargetTextField
                            secondTextField:(UITextField **)secondTargetTextField
{
    UIView *view = [[UIView alloc] init];
    
    UIView *firstInputFieldView = [self inputFieldAtYPoint:0
                                       withPlaceholderText:firstPlaceholder
                                                  infoText:nil
                                           backgroundImage:[UIImage imageNamed:@"RegistrationInputFieldUpperBg"]
                                                 iconImage:nil
                                              forTextField:firstTargetTextField];
    [view addSubview:firstInputFieldView];

    UIView *secondInputFieldView = [self inputFieldAtYPoint:firstInputFieldView.frame.size.height
                                        withPlaceholderText:secondPlaceholder
                                                   infoText:infoText
                                            backgroundImage:[UIImage imageNamed:@"RegistrationInputFieldLowerBg"]
                                                  iconImage:nil
                                               forTextField:secondTargetTextField];
    [view addSubview:secondInputFieldView];
    
    view.frame = CGRectMake(0,
                            yPoint,
                            self.view.frame.size.width,
                            secondInputFieldView.frame.origin.y + secondInputFieldView.frame.size.height);
    
    return view;
}

- (UIView *)inputFieldForBirthdayAtYPoint:(CGFloat)yPoint
                             forTextField:(UITextField **)targetTextField
{
    UIView *view = [self inputFieldAtYPoint:yPoint
                        withPlaceholderText:@"Birthday"
                                   infoText:nil
                            backgroundImage:[UIImage imageNamed:@"RegistrationInputFieldBg"]
                                  iconImage:[UIImage imageNamed:@"RegistrationCalendarIcon"]
                               forTextField:targetTextField];
    
    return view;
}

- (UIView *)uploadButtonViewAtYPoint:(CGFloat)yPoint
                        withSelector:(SEL)selector
                         targetLabel:(UILabel **)targetLabel
{
    UIView *view = [self buttonViewAtYPoint:yPoint
                               withSelector:selector
                                     target:self
                                       icon:[UIImage imageNamed:@"RegistrationPhotoIcon"]
                                  labelText:@"Upload Your Photo ID"
                                targetLabel:targetLabel];
    return view;
}

- (UIView *)checkboxViewAtYPoint:(CGFloat)yPoint
{
    NSString *labelText = @"I accept the Terms and Conditions and Privacy Policy";
    TTTAttributedLabel *label;
    UIButton *checkboxButton;
    UIView *view = [self checkboxViewAtYPoint:yPoint
                        targetAttributedLabel:&label
                                    labelText:labelText
                                 targetButton:&checkboxButton
                               buttonSelector:@selector(checkboxSelected)];
    
    self.checkboxButton = checkboxButton;
    
    NSRange termsAndConditionsLinkRange = [labelText rangeOfString:@"Terms and Conditions"];
    [label addLinkToURL:[NSURL URLWithString:kSDCommonRegistrationViewControllerTermsAndConditionsLink]
              withRange:termsAndConditionsLinkRange];
    NSRange privacyPolicyLinkRange = [labelText rangeOfString:@"Privacy Policy"];
    [label addLinkToURL:[NSURL URLWithString:kSDCommonRegistrationViewControllerPrivacyPolicyLink]
              withRange:privacyPolicyLinkRange];
    
    return view;
}

- (UIView *)parentCheckboxViewAtYPoint:(CGFloat)yPoint
{
    UIButton *parentCheckboxButton;
    UIView *view = [self checkboxViewAtYPoint:yPoint
                        targetAttributedLabel:nil
                                    labelText:@"I give permission for my child to use SigningDay and accept the Terms and Conditions and the Privacy Policy on my child's behalf."
                                 targetButton:&parentCheckboxButton
                               buttonSelector:@selector(parentCheckboxSelected)];
    self.parentCheckboxButton = parentCheckboxButton;
    
    return view;
}

- (UIView *)greenButtonViewAtYPoint:(CGFloat)yPoint
                          withTitle:(NSString *)title
                           selector:(SEL)selector
{
    UIView *view = [[UIView alloc] init];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"RegistrationGreenButtonBg"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:backgroundImage
                      forState:UIControlStateNormal];
    button.frame = CGRectMake(kSDCommonRegistrationViewControllerLeftPadding,
                              0,
                              backgroundImage.size.width,
                              backgroundImage.size.height);
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor colorWithRed:0.0f
                                        green:0.0f
                                         blue:0.0f
                                        alpha:0.5f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    label.userInteractionEnabled = NO;
    label.exclusiveTouch = NO;
    [label sizeToFit];
    label.center = button.center;
    [button addSubview:label];
    
    [view addSubview:button];
    
    view.frame = CGRectMake(0,
                            yPoint,
                            self.view.frame.size.width,
                            button.frame.size.height);
    
    return view;
}

- (UIView *)topViewWithActivationNotificationLabelAtYPoint:(CGFloat)yPoint
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    NSString *labelText = @"Please complete the form below or follow us on Twitter @Signing_Day and we will DM you the invitation to take over your profile";
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] init];
    label.delegate = self;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:102.0f/255.0f
                                      green:102.0f/255.0f
                                       blue:102.0f/255.0f
                                      alpha:1.0f];
    label.font = [UIFont systemFontOfSize:16];
    label.activeLinkAttributes = nil;
    label.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:YES]};
    label.text = labelText; // ALWAYS SET THE TEXT LAST
    
    CGSize calculatedSize = [label sizeThatFits:CGSizeMake(260,
                                                           CGFLOAT_MAX)];
    
    NSRange twitterLinkRange = [labelText rangeOfString:@"@Signing_Day"];
    [label addLinkToURL:[NSURL URLWithString:kSDCommonRegistrationViewControllerTwitterLink]
              withRange:twitterLinkRange];
    
    view.frame = CGRectMake(0,
                            yPoint,
                            self.view.frame.size.width,
                            calculatedSize.height + 12*2);
    CGRect labelFrame = label.frame;
    labelFrame.size = calculatedSize;
    labelFrame.origin = CGPointMake((view.frame.size.width - calculatedSize.width)/2,
                                    (view.frame.size.height - calculatedSize.height)/2);
    label.frame = labelFrame;
    
    [view addSubview:label];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor colorWithRed:190.0f/255.0f
                                               green:190.0f/255.0f
                                                blue:190.0f/255.0f
                                               alpha:1.0f].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0,
                                    CGRectGetHeight(view.frame) + 1,
                                    CGRectGetWidth(view.frame),
                                    1);
    
    [view.layer addSublayer:bottomBorder];
    
    return view;
}

- (UIView *)viewForNoticeLabelAtYPoint:(CGFloat)yPoint
{
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = @"Please use your school ID. Do not upload a government issued ID (drivers license, passport, etc).\nYour photo ID will be reviewed by SigningDay staff only. This is required to verify your identity.";
    label.textColor = [UIColor colorWithRed:165.0f/255.0f
                                      green:165.0f/255.0f
                                       blue:165.0f/255.0f
                                      alpha:1.0f];
    label.textAlignment = NSTextAlignmentCenter;
    CGRect labelFrame = label.frame;
    CGSize calculatedSize = [label sizeThatFits:CGSizeMake(kSDCommonRegistrationViewControllerContentWidth,
                                                               CGFLOAT_MAX)];
    labelFrame.size = CGSizeMake(kSDCommonRegistrationViewControllerContentWidth,
                                     calculatedSize.height);
    labelFrame.origin = CGPointMake(kSDCommonRegistrationViewControllerLeftPadding,
                                        0);
    label.frame = labelFrame;
    
    view.frame = CGRectMake(0,
                            yPoint,
                            self.view.frame.size.width,
                            labelFrame.size.height);
    [view addSubview:label];
    
    return view;
}

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    
}

@end