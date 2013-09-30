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
    
    self.title = @"Video";
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    
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
//    NSString* embedHTML = @"\
//    <html><head>\
//    <style type=\"text/css\">\
//    body {\
//    background-color: transparent;\
//    color: white;\
//    }\
//    </style>\
//    </head><body style=\"margin:0\">\
//    <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
//    width=\"%0.0f\" height=\"%0.0f\"></embed>\
//    </body></html>";
//
//    NSString* html = [NSString stringWithFormat:embedHTML, formatedUrl, frame.size.width, frame.size.height];
    
    CGRect frame = self.view.frame;
    NSString *formatedUrl = [self getYoutubeUrlStr:self.urlLink];
    
    UIWebView *videoView = [[UIWebView alloc] initWithFrame:frame];
    videoView.autoresizesSubviews = YES;
    
    videoView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
//    NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 212\"/></head><body style=\"background:#000000;margin-top:0px;margin-left:0px\"><div><object width=\"%0.0f\" height=\"%0.0f\"><param name=\"movie\" value=\"%@\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"%@\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"320\" height=\"480\"></embed></object></div></body></html>",frame.size.width,frame.size.height,formatedUrl,formatedUrl];
//    [videoView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"<html><head></head><body style=\"margin-top:0px;margin-left:0px\">"];
    [str appendFormat:@"<iframe width=\"%0.0f\" height=\"%0.0f\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>",frame.size.width,frame.size.height,formatedUrl];
    [str appendFormat:@"</div></body></html>"];
    
    [videoView loadHTMLString:str baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
    
    videoView.delegate = self;
    [self.view addSubview:videoView];
    
//    [videoView loadHTMLString:html baseURL:nil];
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
