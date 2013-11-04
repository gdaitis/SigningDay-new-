//
//  SDBaseChatViewController.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseViewController.h"

static CGFloat const kMessageFontSize   = 14.0f;
static CGFloat const kMessageTextWidth  = 242.0f;
static CGFloat const kContentHeightMax  = 104.0f;
static CGFloat const kChatBarHeight1    = 50.0f;
static CGFloat const kChatBarHeight4    = 104.0f;

@class SDContentHeaderView;

@interface SDBaseChatViewController : SDBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *chatBar;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UITextView *enterMessageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *textViewBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) CGFloat previousContentHeight;

@property (nonatomic, strong) SDContentHeaderView *contentHeaderView;

@property (nonatomic, strong) NSArray *dataArray;

- (void)checkServer;
- (void)send;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)resizeViewWithOptions:(NSDictionary *)options;
- (void)closeKeyboard;
- (void)enableSendButton;
- (void)disableSendButton;
- (void)resetSendButton;
- (void)clearChatInput;
- (void)scrollToBottomAnimated:(BOOL)animated;

- (int)yCoordinateOfTableView;

@end
