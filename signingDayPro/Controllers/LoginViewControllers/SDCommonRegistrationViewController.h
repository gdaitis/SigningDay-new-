//
//  SDCommonRegistrationViewController.h
//  SigningDay
//
//  Created by lite on 02/01/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDBaseViewController.h"
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

extern NSString * const kSDCommonRegistrationViewControllerTermsAndConditionsLink;
extern NSString * const kSDCommonRegistrationViewControllerPrivacyPolicyLink;
extern NSString * const kSDCommonRegistrationViewControllerTwitterLink;

@interface SDCommonRegistrationViewController : SDBaseViewController <UITextFieldDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *checkboxButton;
@property (nonatomic, strong) UIButton *parentCheckboxButton;
@property (nonatomic, strong) UIView *contentView;

- (UIView *)createContentView;
- (BOOL)validateEmailWithString:(NSString*)email;
- (BOOL)validateUsernamelWithString:(NSString*)username;

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
- (UIView *)inputFieldForBirthdayAtYPoint:(CGFloat)yPoint
                             forTextField:(UITextField **)targetTextField;
- (UIView *)uploadButtonViewAtYPoint:(CGFloat)yPoint
                        withSelector:(SEL)selector
                         targetLabel:(UILabel **)targetLabel;
- (UIView *)checkboxViewAtYPoint:(CGFloat)yPoint;
- (UIView *)parentCheckboxViewAtYPoint:(CGFloat)yPoint;
- (UIView *)greenButtonViewAtYPoint:(CGFloat)yPoint
                          withTitle:(NSString *)title
                           selector:(SEL)selector;
- (UIView *)topViewWithActivationNotificationLabelAtYPoint:(CGFloat)yPoint;
- (UIView *)viewForNoticeLabelAtYPoint:(CGFloat)yPoint;

@end
