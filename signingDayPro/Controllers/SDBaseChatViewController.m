//
//  SDBaseChatViewController.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseChatViewController.h"
#import "NSString+Additions.h"
#import "SDContentHeaderView.h"
#import "SDAppDelegate.h"

@implementation SDBaseChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *image = [UIImage imageNamed:@"back_nav_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.tableView.clearsContextBeforeDrawing = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.tableView addGestureRecognizer:recognizer];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg.png"]];
    [imageView setFrame:self.tableView.bounds];
    [self.tableView setBackgroundView:imageView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.chatBar.frame = CGRectMake(0.0f,
                                    self.containerView.frame.size.height-kChatBarHeight1,
                                    self.containerView.frame.size.width,
                                    kChatBarHeight1);
    self.chatBar.clearsContextBeforeDrawing = NO;
    self.chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.chatBar.userInteractionEnabled = YES;
    
    self.enterMessageTextView.frame = CGRectMake(10, 10, 230, 30);
    
    self.textViewBackgroundImageView.image = [[UIImage imageNamed:@"chat_box_text_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.textViewBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.textViewBackgroundImageView.frame = self.enterMessageTextView.frame;
    
    self.enterMessageTextView.delegate = self;
    self.enterMessageTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.enterMessageTextView.scrollEnabled = NO; // not initially
    self.enterMessageTextView.clearsContextBeforeDrawing = NO;
    self.enterMessageTextView.font = [UIFont systemFontOfSize:kMessageFontSize];
    self.enterMessageTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.enterMessageTextView.backgroundColor = [UIColor clearColor];
    self.previousContentHeight = self.enterMessageTextView.contentSize.height;
    
    [self.chatBar addSubview:self.textViewBackgroundImageView];
    [self.chatBar addSubview:self.enterMessageTextView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    line.backgroundColor = [UIColor blackColor];
    line.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    line.clearsContextBeforeDrawing = NO;
    [self.chatBar addSubview:line];
    
    self.sendButton.clearsContextBeforeDrawing = NO;
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.frame = CGRectMake(250, 10, self.sendButton.frame.size.width, self.sendButton.frame.size.height);
    [self resetSendButton]; // disable initially
    [self.chatBar addSubview:self.sendButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self closeKeyboard];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setEnterMessageTextView:nil];
    [self setChatBar:nil];
    [self setSendButton:nil];
    [self setTextViewBackgroundImageView:nil];
    [self setContainerView:nil];
    [self setHeaderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)checkServer
{
    // override me
}

- (void)send
{
    // override me
}

#pragma mark - Keyboards

- (void)hideAllHeyboards
{
    [self.enterMessageTextView resignFirstResponder];
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
    CGRect viewFrame = self.containerView.frame;
    
    CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    float y = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        y = 20;
    
    viewFrame.size.height =  keyboardFrameEndRelative.origin.y - y;
    self.containerView.frame = viewFrame;
    [UIView commitAnimations];
    
    [self scrollToBottomAnimated:YES];
}

- (void)closeKeyboard
{
    [self.enterMessageTextView resignFirstResponder];
}

#pragma mark 

- (void)enableSendButton
{
    if (self.sendButton.enabled == NO) {
        self.sendButton.enabled = YES;
    }
}

- (void)disableSendButton
{
    if (self.sendButton.enabled == YES) {
        [self resetSendButton];
    }
}

- (void)resetSendButton
{
    self.sendButton.enabled = NO;
}

- (void)clearChatInput
{
    self.enterMessageTextView.text = @"";
    if (self.previousContentHeight > 22.0f) {
        [self resetChatBarHeight];
        [self scrollToBottomAnimated:YES];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger bottomRow = [self.dataArray count] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:animated];
    }
}

#pragma mark 

- (void)resetChatBarHeight
{
    [self setChatBarHeight:kChatBarHeight1];
}

- (void)expandChatBarHeight
{
    [self setChatBarHeight:kChatBarHeight4];
}

- (int)yCoordinateOfTableView
{
    return 84;
}

- (void)setChatBarHeight:(NSInteger)height
{
    NSInteger viewHeight = self.containerView.frame.size.height;
    NSInteger viewWidth = self.containerView.frame.size.width;
    float y = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        y = 20;
    NSInteger viewY = self.yCoordinateOfTableView - y;
    
    CGRect chatContentFrame = self.tableView.frame;
    chatContentFrame.size.height = viewHeight - height - viewY;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    self.tableView.frame = chatContentFrame;
    self.chatBar.frame = CGRectMake(self.chatBar.frame.origin.x,
                                    chatContentFrame.size.height + viewY,
                                    viewWidth,
                                    height);
    [UIView commitAnimations];
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    int contentHeight;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        CGRect frame = textView.bounds;
        CGSize fudgeFactor;
        // The padding added around the text on iOS6 and iOS7 is different.
        fudgeFactor = CGSizeMake(10.0, 16.0);
        
        frame.size.height -= fudgeFactor.height;
        frame.size.width -= fudgeFactor.width;
        
        NSMutableAttributedString* textToMeasure;
        if(textView.attributedText && textView.attributedText.length > 0){
            textToMeasure = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
        }
        else{
            textToMeasure = [[NSMutableAttributedString alloc] initWithString:textView.text];
            [textToMeasure addAttribute:NSFontAttributeName value:textView.font range:NSMakeRange(0, textToMeasure.length)];
        }
        
        if ([textToMeasure.string hasSuffix:@"\n"])
        {
            [textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName: textView.font}]];
        }
        
        // NSAttributedString class method: boundingRectWithSize:options:context is
        // available only on ios7.0 sdk.
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil];
        
        contentHeight = CGRectGetHeight(size) + fudgeFactor.height;
#else
    contentHeight = textView.contentSize.height;
#endif
    
    NSString *rightTrimmedText = @"";
    
    if ([textView hasText]) {
        rightTrimmedText = [textView.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
        
        if (contentHeight != self.previousContentHeight) {
            if (contentHeight <= kContentHeightMax) {
                if (contentHeight == 32) {
                    [self resetChatBarHeight];
                } else {
                    CGFloat chatBarHeight = contentHeight + 16 + 6;
                    [self setChatBarHeight:chatBarHeight];
                }
                if (self.previousContentHeight > kContentHeightMax) {
                    textView.scrollEnabled = NO;
                }
                // textView.contentOffset = CGPointMake(0.0f, 6.0f);
                [self scrollToBottomAnimated:YES];
            } else if (self.previousContentHeight <= kContentHeightMax) {
                textView.scrollEnabled = YES;
                textView.contentOffset = CGPointMake(0.0f, contentHeight-63.0f);
                if (self.previousContentHeight < kContentHeightMax) {
                    [self expandChatBarHeight];
                    [self scrollToBottomAnimated:YES];
                }
            }
        }
    } else {
        if (self.previousContentHeight > 22.0f) {
            [self resetChatBarHeight];
            if (self.previousContentHeight > kContentHeightMax) {
                textView.scrollEnabled = NO;
            }
        }
    }
    
    if (rightTrimmedText.length > 0) {
        [self enableSendButton];
    } else {
        [self disableSendButton];
    }
    
    self.previousContentHeight = contentHeight;
}

@end
