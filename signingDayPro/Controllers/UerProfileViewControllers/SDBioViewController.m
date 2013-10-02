//
//  SDBioViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBioViewController.h"
#import "User.h"
#import "SDProfileService.h"
#import <QuartzCore/QuartzCore.h>

@interface SDBioViewController ()

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation SDBioViewController

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
    [self checkServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DataLoading

- (void)checkServer
{
    [self loadBio];
    [SDProfileService getBasicProfileInfoForUserIdentifier:self.currentUser.identifier completionBlock:^{
            [self loadBio];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        NSLog(@"getBasicProfileInfoForUserIdentifier FAILED in BioViewController");
        [self hideProgressHudInView:self.view];
    }];
}

- (void)loadBio
{
    if (self.currentUser) {
        if (self.currentUser.bio)
        {
            NSString *text = [self.currentUser.bio stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (text.length > 0)
                self.textView.text = self.currentUser.bio;
            else
                self.textView.text = @"N/A";
        }
        else {
            [self showProgressHudInView:self.view withText:@"Loading"];
            self.textView.text = @"N/A";
        }
        
    }
}

@end
