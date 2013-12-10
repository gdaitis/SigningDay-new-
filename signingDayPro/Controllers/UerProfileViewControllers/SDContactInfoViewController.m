//
//  SDContactInfoViewController.m
//  SigningDay
//
//  Created by lite on 05/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDContactInfoViewController.h"
#import "TTTAttributedLabel.h"
#import "SDProfileService.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"

#define kSDBioViewControllerBioLabelTopPadding 16
#define kSDBioViewControllerContactsInfoLabelsWidth 223
#define kSDBioViewControllerContactsInfoLabelsVerticalSpacing 20
#define kSDBioViewControllerBottomLineTopPadding 23

@interface SDContactInfoViewController () <TTTAttributedLabelDelegate>

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *mobileInfoLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *emailInfoLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *addressInfoLabel;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) CAGradientLayer *shadowLayer;

@end

@implementation SDContactInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self resizeTitleLabels];
    
    [self loadContactInfo];
    [self checkServer];
}

- (void)resizeTitleLabels
{
    [self.contactsLabel sizeToFit];
    [self.mobileLabel sizeToFit];
    [self.emailLabel sizeToFit];
    [self.addressLabel sizeToFit];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.screenName = @"Contact Info screen";
}

#pragma mark - DataLoading

- (void)checkServer
{
    void (^completionBlock)(void) = ^(void) {
        [self loadContactInfo];
        [self hideProgressHudInView:self.view];
    };
    
    [self showProgressHudInView:self.view
                       withText:@"Loading"];
    [SDProfileService getAllContactInfoForUserIdentifier:self.currentUser.identifier
                                         completionBlock:completionBlock
                                            failureBlock:completionBlock];
}

- (void)loadContactInfo
{
    NSString *mobileNr = self.currentUser.bioPhone;
    NSString *email = self.currentUser.bioEmail;
    NSString *address = self.currentUser.bioAddress;
    
    [self setupViewWithMobileNr:mobileNr
                          email:email
                        address:address];
}

#pragma mark - Layout methods

- (void)setupViewWithMobileNr:(NSString *)mobileNr
                        email:(NSString *)email
                      address:(NSString *)address
{
    CGFloat currentYPosition = kSDBioViewControllerBioLabelTopPadding;
    
    if (![mobileNr isEqualToString:@""] || ![email isEqualToString:@""] || ![address isEqualToString:@""]) {
        self.contactsLabel.hidden = NO;
        
        [self setupContactsLabelAtYPosition:currentYPosition];
        currentYPosition += self.contactsLabel.frame.size.height;
        
        if (![mobileNr isEqualToString:@""]) {
            self.mobileLabel.hidden = NO;
            self.mobileInfoLabel.hidden = NO;
            
            currentYPosition += kSDBioViewControllerContactsInfoLabelsVerticalSpacing;
            [self setupMobileLabelsAtYPosition:currentYPosition
                                       andText:mobileNr];
            currentYPosition += self.mobileInfoLabel.frame.size.height;
        } else {
            self.mobileLabel.hidden = YES;
            self.mobileInfoLabel.hidden = YES;
        }
        
        if (![email isEqualToString:@""]) {
            self.emailLabel.hidden = NO;
            self.emailInfoLabel.hidden = NO;
            currentYPosition += kSDBioViewControllerContactsInfoLabelsVerticalSpacing;
            [self setupEmailLabelsAtYPosition:currentYPosition
                                      andText:email];
            currentYPosition += self.emailInfoLabel.frame.size.height;
        } else {
            self.emailLabel.hidden = YES;
            self.emailInfoLabel.hidden = YES;
        }
        
        if (![address isEqualToString:@""]) {
            self.addressLabel.hidden = NO;
            self.addressInfoLabel.hidden = NO;
            
            currentYPosition += kSDBioViewControllerContactsInfoLabelsVerticalSpacing;
            [self setupAddressLabelsAtYPosition:currentYPosition
                                        andText:address];
            currentYPosition += self.addressInfoLabel.frame.size.height;
        } else {
            self.addressLabel.hidden = YES;
            self.addressInfoLabel.hidden = YES;
        }
        currentYPosition += kSDBioViewControllerBottomLineTopPadding;
    } else {
        self.contactsLabel.hidden = YES;
        self.mobileLabel.hidden = YES;
        self.mobileInfoLabel.hidden = YES;
        self.emailLabel.hidden = YES;
        self.emailInfoLabel.hidden = YES;
        self.addressLabel.hidden = YES;
        self.addressInfoLabel.hidden = YES;
        
        currentYPosition += kSDBioViewControllerBottomLineTopPadding;
    }
    
    [self setupBottomLineAtYPosition:currentYPosition];
}

- (void)setupContactsLabelAtYPosition:(CGFloat)yPosition
{
    CGRect contactsLabelFrame = self.contactsLabel.frame;
    contactsLabelFrame.origin.y = yPosition;
    self.contactsLabel.frame = contactsLabelFrame;
}

- (CGSize)contactsInfoLabelsFitSize
{
    return CGSizeMake(kSDBioViewControllerContactsInfoLabelsWidth, CGFLOAT_MAX);
}

- (void)setupMobileLabelsAtYPosition:(CGFloat)yPosition andText:(NSString *)mobileText
{
    CGRect mobileLabelFrame = self.mobileLabel.frame;
    mobileLabelFrame.origin.y = yPosition;
    self.mobileLabel.frame = mobileLabelFrame;
    
    self.mobileInfoLabel.linkAttributes = nil;
    self.mobileInfoLabel.delegate = self;
    self.mobileInfoLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    self.mobileInfoLabel.text = mobileText;
    
    CGSize mobileInfoLabelSize = [self.mobileInfoLabel sizeThatFits:self.contactsInfoLabelsFitSize];
    CGRect mobileInfoLabelFrame = self.mobileInfoLabel.frame;
    mobileInfoLabelFrame.origin.y = self.mobileLabel.frame.origin.y;
    mobileInfoLabelFrame.size = mobileInfoLabelSize;
    self.mobileInfoLabel.frame = mobileInfoLabelFrame;
}

- (void)setupEmailLabelsAtYPosition:(CGFloat)yPosition andText:(NSString *)emailText
{
    CGRect emailLabelFrame = self.emailLabel.frame;
    emailLabelFrame.origin.y = yPosition;
    self.emailLabel.frame = emailLabelFrame;
    
    self.emailInfoLabel.linkAttributes = nil;
    self.emailInfoLabel.delegate = self;
    self.emailInfoLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    self.emailInfoLabel.text = emailText;
    
    CGSize emailInfoLabelSize = [self.emailInfoLabel sizeThatFits:self.contactsInfoLabelsFitSize];
    CGRect emailInfoLabelFrame = self.emailInfoLabel.frame;
    emailInfoLabelFrame.origin.y = self.emailLabel.frame.origin.y;
    emailInfoLabelFrame.size = emailInfoLabelSize;
    self.emailInfoLabel.frame = emailInfoLabelFrame;
}

- (void)setupAddressLabelsAtYPosition:(CGFloat)yPosition andText:(NSString *)addressText
{
    CGRect addressLabelFrame = self.addressLabel.frame;
    addressLabelFrame.origin.y = yPosition;
    self.addressLabel.frame = addressLabelFrame;
    
    self.addressInfoLabel.linkAttributes = nil;
    self.addressInfoLabel.delegate = self;
    self.addressInfoLabel.text = addressText;
    NSRange range = (NSRange){0, addressText.length};
    NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", [addressText stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    [self.addressInfoLabel addLinkToURL:[NSURL URLWithString:urlString] withRange:range];
    
    CGSize addressInfoLabelSize = [self.addressInfoLabel sizeThatFits:self.contactsInfoLabelsFitSize];
    CGRect addressInfoLabelFrame = self.addressInfoLabel.frame;
    addressInfoLabelFrame.origin.y = self.addressLabel.frame.origin.y;
    addressInfoLabelFrame.size = addressInfoLabelSize;
    self.addressInfoLabel.frame = addressInfoLabelFrame;
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

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}


@end
