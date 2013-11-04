//
//  SDBuzzSomethingViewController.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBuzzSomethingViewController.h"
#import "SDModalNavigationController.h"
#import "User.h"
#import "SDActivityFeedService.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"

@interface SDBuzzSomethingViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

- (void)closeButtonPressed;
- (void)postButtonPressed;

@end

@implementation SDBuzzSomethingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = [UIImage imageNamed:@"MenuButtonClose.png"];
    [btn addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIImage *image = [UIImage imageNamed:@"MenuButtonPost.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = doneButtonItem;

    self.userImageView.layer.cornerRadius = 4.0f;
    self.userImageView.clipsToBounds = YES;
    
    self.textView.textColor = [UIColor colorWithRed:102/255
                                              green:102/255
                                               blue:102/255
                                              alpha:1];
    self.textView.font = [UIFont systemFontOfSize:18];
    
    User *user = [self getMasterUser];
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    
    [self.textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Buzz something screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeButtonPressed
{
    SDModalNavigationController *modalNavigationController = (SDModalNavigationController *)self.navigationController;
    [modalNavigationController closePressed];
}

- (void)postButtonPressed
{
    void (^successBlock)(void) = ^{
        [self hideProgressHudInView:self.contentView];
        [self closeButtonPressed];
    };
    
    void (^failureBlock)(void) = ^{
        NSLog(@"ERROR WHILE POSTING");
        [self hideProgressHudInView:self.contentView];
        [self closeButtonPressed];
    };
    
    [self showProgressHudInView:self.contentView withText:@"Posting"];
    if (self.user) {
        [SDActivityFeedService postActivityStoryWithMessageBody:self.textView.text
                                                        forUser:self.user
                                                   successBlock:successBlock
                                                   failureBlock:failureBlock];
    } else {
        [SDActivityFeedService postActivityStoryWithMessageBody:self.textView.text
                                                   successBlock:successBlock
                                                   failureBlock:failureBlock];
    }
}

@end
