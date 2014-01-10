//
//  SDTermsOfServiceViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/15/12.
//
//

#import "SDTermsViewController.h"
#import "SDAPIClient.h"
#import "SDStandartNavigationController.h"

@implementation SDTermsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    /p/terms.aspx
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSString *fullUrlString = [NSString stringWithFormat:@"%@%@", kSDBaseSigningDayURLString,_urlString];
    NSURL *url = [NSURL URLWithString:fullUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    UIImage *image = [UIImage imageNamed:@"back_nav_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self.navigationController class] isSubclassOfClass:[SDStandartNavigationController class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [(SDStandartNavigationController *)self.navigationController setNavigationTitle:self.navigationTitle];
        CGRect frame = self.webView.frame;
        frame.size.height = self.view.bounds.size.height;
        frame.origin.y = 0;
        self.webView.frame = frame;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Terms screen";
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
