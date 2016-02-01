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

#define kSDBioViewControllerBioLabelTopPadding 16
#define kSDBioViewControllerBioLabelBottomPadding 12
#define kSDBioViewControllerBioInfoLabelBottomPadding 25
#define kSDBioViewControllerBioInfoLabelWidth 300
#define kSDBioViewControllerBottomLineTopPadding 23

@interface SDBioViewController ()

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioInfoLabel;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) CAGradientLayer *shadowLayer;

@end

@implementation SDBioViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self resizeTitleLabels];
    
    [self loadBio];
    [self checkServer];
}

- (void)resizeTitleLabels
{
    [self.bioLabel sizeToFit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Bio screen";
}

#pragma mark - DataLoading

- (void)checkServer
{
    void (^completionBlock)(void) = ^(void) {
        [self loadBio];
        [self hideProgressHudInView:self.view];
    };
    
    [self showProgressHudInView:self.view
                       withText:@"Loading"];
    [SDProfileService getBasicProfileInfoForUserIdentifier:self.currentUser.identifier
                                           completionBlock:^{
                                               completionBlock();
                                           } failureBlock:^{
                                               NSLog(@"getBasicProfileInfoForUserIdentifier FAILED in BioViewController");
                                               completionBlock();
    }];
}

- (void)loadBio
{
    NSString *bio = self.currentUser.bio;//@"This is a long bio. This is a long bio. This is";
    if (self.currentUser) {
        if (self.currentUser.bio) {
            NSString *text = [self.currentUser.bio stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (text.length > 0)
                bio = self.currentUser.bio;
            else
                bio = [NSString stringWithFormat:@"%@ has not posted a bio",self.currentUser.name];
        }
    }
    [self setupViewWithBio:bio];
}

#pragma mark - Layout methods

- (void)setupViewWithBio:(NSString *)bio
{
    CGFloat currentYPosition = kSDBioViewControllerBioLabelTopPadding;
    [self setupBioLabelAtYPosition:currentYPosition];
    currentYPosition += self.bioLabel.frame.size.height + kSDBioViewControllerBioLabelBottomPadding;
    
    [self setupBioInfoLabelAtYPosition:currentYPosition
                               andText:bio];
    currentYPosition += self.bioInfoLabel.frame.size.height;
    currentYPosition += kSDBioViewControllerBottomLineTopPadding;
    
    [self setupBottomLineAtYPosition:currentYPosition];
}

- (void)setupBioLabelAtYPosition:(CGFloat)yPosition
{
    CGRect bioLabelFrame = self.bioLabel.frame;
    bioLabelFrame.origin.y = yPosition;
    self.bioLabel.frame = bioLabelFrame;
}

- (void)setupBioInfoLabelAtYPosition:(CGFloat)yPosition andText:(NSString *)bioText
{
    self.bioInfoLabel.text = bioText;
    CGSize bioFitSize = CGSizeMake(kSDBioViewControllerBioInfoLabelWidth, CGFLOAT_MAX);
    CGSize bioInfoLabelSize = [self.bioInfoLabel sizeThatFits:bioFitSize];
    CGRect bioInfoLabelFrame = self.bioInfoLabel.frame;
    bioInfoLabelFrame.origin.y = yPosition;
    bioInfoLabelFrame.size = bioInfoLabelSize;
    self.bioInfoLabel.frame = bioInfoLabelFrame;
}

- (void)setupBottomLineAtYPosition:(CGFloat)yPosition
{
    if (self.bottomLine)
        [self.bottomLine removeFromSuperview];
    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.backgroundColor = [UIColor colorWithRed:168.0f/255.0f
                                                      green:168.0f/255.0f
                                                       blue:168.0f/255.0f
                                                      alpha:1.0f];
    CGRect bottomLineFrame = CGRectMake(0, 0, 0, 0);
    bottomLineFrame.origin.x = 0;
    bottomLineFrame.origin.y = yPosition;
    bottomLineFrame.size.width = 320;
    bottomLineFrame.size.height = 1;
    self.bottomLine.frame = bottomLineFrame;
    [self.backgroundView addSubview:self.bottomLine];
    
    CGRect backgroundViewFrame = self.backgroundView.frame;
    backgroundViewFrame.size.height = self.bottomLine.frame.origin.y + self.bottomLine.frame.size.height;
    self.backgroundView.frame = backgroundViewFrame;
    
    if (self.shadowLayer)
        [self.shadowLayer removeFromSuperlayer];
    self.shadowLayer = [[CAGradientLayer alloc] init];
    self.shadowLayer.frame = CGRectMake(0,
                                        self.backgroundView.frame.size.height,
                                        self.backgroundView.frame.size.width,
                                        4);
    CGColorRef darkColor = [UIColor colorWithRed:203.0f/255.0f green:203.0f/255.0f blue:203.0f/255.0f alpha:1.0f].CGColor;
    CGColorRef lightColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f].CGColor;
    self.shadowLayer.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
    [self.backgroundView.layer addSublayer:self.shadowLayer];
}

@end
