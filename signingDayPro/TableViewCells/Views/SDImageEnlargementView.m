//
//  SDImageEnlargementView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDImageEnlargementView.h"

@interface SDImageEnlargementView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SDImageEnlargementView

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupViewWithImage:image];
    }
    return self;
}

- (void)setupViewWithImage:(UIImage *)image
{
    //creating uiscrollview for image zooming, and adding UIImageView
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.imageView.image = image;
    self.scrollView.contentSize = self.imageView.frame.size;
    [self.scrollView addSubview:self.imageView];
    
    [self addSubview:self.scrollView];
    
    //adding closeButton
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeButton.frame = CGRectMake(self.bounds.size.width-60, 10, 50, 50); //creating button to be 10px from top and 10px from the right side
    [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
