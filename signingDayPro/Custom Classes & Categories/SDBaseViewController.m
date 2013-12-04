//
//  SDBaseViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseViewController.h"
#import "MBProgressHUD.h"
#import "Master.h"
#import "User.h"
#import "SDLoginService.h"
#import "SDNavigationController.h"
#import "IIViewDeckController.h"
#import "ActivityStory.h"
#import <MediaPlayer/MediaPlayer.h>

NSString * const SDKeyboardShouldHideNotification = @"SDKeyboardShouldHideNotification";

@interface SDBaseViewController ()

@end

@implementation SDBaseViewController

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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(checkServer) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideAllHeyboards)
                                                 name:SDKeyboardShouldHideNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SDKeyboardShouldHideNotification
                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //If view controller has self.navigationTitle, it means we want to show title instead of fav,msg,follow buttons
    SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
    if (self.navigationTitle) {
        if (navigationController)
            [navigationController setTitle:self.navigationTitle];
    }
    else {
        [navigationController setTitle:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showProgressHudInView:(UIView *)view withText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (text) {
        hud.labelText = text;
    }
}

- (void)hideProgressHudInView:(UIView *)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

#pragma mark - Keyboards

- (void)hideAllHeyboards
{
    // override me
}

#pragma mark - Loader methods

- (void)beginRefreshing
{
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
}

- (void)endRefreshing
{
    [self.refreshControl endRefreshing];
}

- (void)checkServer
{
    // override this in a subclass
}

- (void)showAlertWithTitle:(NSString *)title andText:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - video stuff

- (void)playVideoWithActivityStory:(ActivityStory *)activityStory
{
    [self playVideoWithMediaFileUrlString:activityStory.mediaUrl];
}

- (void)playVideoWithMediaFileUrlString:(NSString *)urlString
{
    if ([urlString rangeOfString:@"signingday"].location == NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else {
        //signingday link
        NSURL *url = [NSURL URLWithString:urlString];
        [self playVideoWithUrl:url];
    }
}

- (void)playVideoWithUrl:(NSURL *)url
{
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] init];
    [player.moviePlayer setContentURL:url];
    player.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    player.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [player.view setFrame:self.view.bounds];
    [player.moviePlayer prepareToPlay];
    
    [self presentMoviePlayerViewControllerAnimated:player];
    [player.moviePlayer play];
}

@end
