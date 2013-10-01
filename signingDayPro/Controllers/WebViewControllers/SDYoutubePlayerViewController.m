//
//  SDYoutubePlayerViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDYoutubePlayerViewController.h"
#import "SDModalNavigationController.h"

@interface SDYoutubePlayerViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation SDYoutubePlayerViewController

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
    
    UIImage *image = [UIImage imageNamed:@"MenuButtonClose.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView
{
    CGRect frame = self.view.frame;
    NSString *formatedUrl = [self getYoutubeUrlStr:self.urlLink];

    BOOL smallScreen = NO;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (!([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f)) {
        smallScreen = YES;
    }
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"<html><head></head><body style=\"margin-top:0px;margin-left:0px;background-color: black;color:black\">"];
    if (smallScreen)
        [str appendFormat:@"<iframe width=\"%0.0f\" height=\"400\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>",frame.size.width,formatedUrl];
    else
        [str appendFormat:@"<iframe width=\"%0.0f\" height=\"500\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>",frame.size.width,formatedUrl];
    [str appendFormat:@"</div></body></html>"];
    
    [self.webView loadHTMLString:str baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
    self.webView.delegate = self;
    [self.webView.scrollView setScrollEnabled:NO];
}

- (NSString*) getYoutubeUrlStr:(NSString*)url
{
    if (url == nil)
        return nil;
    
    NSString *retVal = [url stringByReplacingOccurrencesOfString:@"watch?v=" withString:@"embed/"];
    NSString *result = [NSString stringWithFormat:@"%@?rel=0",retVal];
    return result;
}

//- (NSString*) getYoutubeUrlStr:(NSString*)url
//{
//    if (url == nil)
//        return nil;
//    
//    NSString *retVal = [url stringByReplacingOccurrencesOfString:@"watch?v=" withString:@"v/"];
//    
//    NSRange pos=[retVal rangeOfString:@"version"];
//    if(pos.location == NSNotFound)
//    {
//        retVal = [retVal stringByAppendingString:@"?version=3&hl=en_EN"];
//    }
//    return retVal;
//}

- (void)cancelButtonPressed
{
    SDModalNavigationController *modalNavigationController = (SDModalNavigationController *)self.navigationController;
    [modalNavigationController closePressed];
}

#pragma mark - delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end
