//
//  SDCommonRegistrationViewController.h
//  SigningDay
//
//  Created by lite on 02/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

#define kSDCommonRegistrationViewControllerTopPadding 16
#define kSDCommonRegistrationViewControllerBottomPadding 43
#define kSDCommonRegistrationViewControllerLeftPadding 9
#define kSDCommonRegistrationViewControllerContentWidth 298
#define kSDCommonRegistrationViewControllerInputFieldVerticalSpacing 15
#define kSDCommonRegistrationViewControllerInputFieldContentWidth 278
#define kSDCommonRegistrationViewControllerInputFieldContentHeight 24
#define kSDCommonRegistrationViewControllerInputFieldBottomPadding 2
#define kSDCommonRegistrationViewControllerInputFieldInnerLeftPadding 14

NSString * const kSDCommonRegistrationViewControllerTermsAndConditionsLink = @"SDCommonRegistrationViewControllerTermsAndConditionsLink";
NSString * const kSDCommonRegistrationViewControllerPrivacyPolicyLink = @"SDCommonRegistrationViewControllerPrivacyPolicyLink";
NSString * const kSDCommonRegistrationViewControllerTwitterLink = @"kSDCommonRegistrationViewControllerTwitterLink";

@interface SDCommonRegistrationViewController : UIViewController <UITextFieldDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) UIButton *checkboxButton;

- (UIView *)createContentView;

- (UIView *)inputFieldAtYPoint:(CGFloat)yPoint
           withPlaceholderText:(NSString *)placeholderText
                      infoText:(NSString *)infoText
                  forTextField:(UITextField **)targetTextField;
- (UIView *)passwordInputFieldsViewAtYPoint:(CGFloat)yPoint
                       withFirstPlaceholder:(NSString *)firstPlaceholder
                          secondPlaceholder:(NSString *)secondPlaceholder
                                   infoText:(NSString *)infoText
                          forFirstTextField:(UITextField **)firstTargetTextField
                            secondTextField:(UITextField **)secondTargetTextField;
- (UIView *)birthdaySelectButtonViewAtYPoint:(CGFloat)yPoint
                                withSelector:(SEL)selector
                                      target:(id)target
                         targetBirthdayLabel:(UILabel **)targetBirthdayLabel;
- (UIView *)uploadButtonViewAtYPoint:(CGFloat)yPoint
                        withSelector:(SEL)selector
                              target:(id)target;
- (UIView *)checkboxViewAtYPoint:(CGFloat)yPoint;
- (UIView *)greenButtonViewAtYPoint:(CGFloat)yPoint
                          withTitle:(NSString *)title
                           selector:(SEL)selector;
- (UIView *)topViewWithActivationNotificationLabelAtYPoint:(CGFloat)yPoint;
- (UIView *)viewForNoticeLabelAtYPoint:(CGFloat)yPoint;

@end
