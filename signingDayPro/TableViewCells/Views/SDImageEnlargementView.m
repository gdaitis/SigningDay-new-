//
//  SDImageEnlargementView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDImageEnlargementView.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface SDImageEnlargementView () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation SDImageEnlargementView

- (id)initWithFrame:(CGRect)frame andImage:(NSString *)imageUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupViewWithImage:imageUrl];
    }
    return self;
}

- (void)setupViewWithImage:(NSString *)imageUrl
{
    //creating uiscrollview for image zooming, and adding UIImageView
    UIScrollView *scrolV = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView = scrolV;
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.frame];
    self.imageView = imageV;
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.delegate = self;
    [self.scrollView addSubview:self.imageView];
    
    [self addSubview:self.scrollView];
    
    //offset for iOS7
    float y = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 15.0 : 0;
    
    //adding closeButton
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(self.bounds.size.width-40, -5+y, 50, 50); //creating button to be in the top right corner
    [closeButton setImage:[UIImage imageNamed:@"closeBtn.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.labelText = @"Loading";
    
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.imageView.image = image;
        [MBProgressHUD hideHUDForView:self animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [MBProgressHUD hideHUDForView:self animated:YES];
    }];
}

- (void)presentImageViewInView:(UIView *)containerView
{
    self.alpha = 0.0f;
    [containerView addSubview:self];
    [UIView animateWithDuration:0.35f animations:^{
        self.alpha = 1.0f;
    } completion:^(__unused BOOL finished) {
    }];
}

- (void)closeView
{
    [UIView animateWithDuration:0.35f animations:^{
        self.alpha = 0.0f;
    } completion:^(__unused BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - uiscrollview delegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return self.imageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
