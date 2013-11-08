//
//  SDNewDiscussionViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 06/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNewDiscussionViewController.h"
#import "SDModalNavigationController.h"
#import "UIPlaceHolderTextView.h"
#import "SDWarRoomService.h"
#import "Forum.h"

@interface SDNewDiscussionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *postTextView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation SDNewDiscussionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    int offset = 10;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        offset = 0;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = [UIImage imageNamed:@"MenuButtonClose.png"];
    [btn addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(-offset, 0, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    UIView *leftButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnImg.size.width, btnImg.size.height)];
    [leftButtonView addSubview:btn];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:leftButtonView];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIImage *image = [UIImage imageNamed:@"MenuButtonPost.png"];
    CGRect frame = CGRectMake(offset, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [rightButtonView addSubview:button];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    self.postTextView.placeholder = @"Write Post Here...";
    self.postTextView.placeholderColor = [UIColor colorWithRed:209.0f/255.0f
                                                         green:209.0f/255.0f
                                                          blue:209.0f/255.0f
                                                         alpha:1];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.postTextView.contentInset = UIEdgeInsetsMake(-4,-4,0,0);
    else
        self.postTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
}

- (void)closeButtonPressed
{
    SDModalNavigationController *modalNavigationController = (SDModalNavigationController *)self.navigationController;
    [modalNavigationController closePressed];
}

- (void)postButtonPressed
{
    if ([self.subjectTextField.text isEqual:@""] || [self.postTextView.text isEqual:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Please fill all of the fields."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    [self showProgressHudInView:self.contentView
                       withText:@"Creating thread"];
    [SDWarRoomService postNewPorumThreadForForumId:self.forum.identifier
                                           subject:self.subjectTextField.text
                                              text:self.postTextView.text
                                   completionBlock:^(Thread *thread) {
                                       [self hideProgressHudInView:self.contentView];
                                       [self.delegate newDiscussionViewController:self
                                                               didCreateNewThread:thread];
                                   } failureBlock:^{
                                       [self hideProgressHudInView:self.contentView];
                                       [self closeButtonPressed];
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                       message:@"Server error occured."
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"Ok"
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                   }];
}

@end
