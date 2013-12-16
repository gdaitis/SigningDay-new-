//
//  SDShareView.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/16/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDShareView.h"
#import "Master.h"
#import <Accounts/Accounts.h>
#import "SDAppDelegate.h"
#import "User.h"
#import <AFNetworking.h>
#import "SDUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface SDShareView ()

@property (nonatomic, strong) User *currentUser;

@property (nonatomic, weak) UILabel *facebookConfigureLabel;
@property (nonatomic, weak) UISwitch *facebookSwitch;
@property (nonatomic, weak) UIButton *facebookConfigureLabelButton;

@property (nonatomic, weak) UILabel *twitterConfigureLabel;
@property (nonatomic, weak) UISwitch *twitterSwitch;
@property (nonatomic, weak) UIButton *twitterConfigureLabelButton;

@property (nonatomic, weak) IBOutlet UIView *blackBackground;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *shareTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelShareButton;

- (IBAction)shareButtonPressed:(UIButton *)sender;
- (IBAction)cancelShareButtonPressed:(UIButton *)sender;

@end

@implementation SDShareView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSocialButtons];
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupSocialButtons];
    [self setupView];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setupView
{
    self.avatarImageView.layer.cornerRadius = 4.0f;
    self.avatarImageView.clipsToBounds = YES;
}

- (void)setupSocialButtons
{
    [self.facebookSwitch removeFromSuperview];
    [self.facebookConfigureLabel removeFromSuperview];
    [self.twitterConfigureLabel removeFromSuperview];
    [self.twitterSwitch removeFromSuperview];
    [self.facebookConfigureLabelButton removeFromSuperview];
    [self.twitterConfigureLabelButton removeFromSuperview];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    
    
    //FACEBOOK Button
    UILabel *faceboolLabel = [[UILabel alloc] initWithFrame:CGRectMake(119, self.facebookTitleLabel.frame.origin.y, 150, 21)];
    self.facebookConfigureLabel = faceboolLabel;
    self.facebookConfigureLabel.text = @"Enable";
    self.facebookConfigureLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    self.facebookConfigureLabel.backgroundColor = [UIColor clearColor];
    self.facebookConfigureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
    self.facebookConfigureLabel.textAlignment = NSTextAlignmentRight;
    
    UIButton *faceBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faceBookButton.frame = self.facebookConfigureLabel.frame;
    [faceBookButton addTarget:self action:@selector(facebookLabelClicked) forControlEvents:UIControlEventTouchUpInside];
    faceBookButton.backgroundColor = [UIColor clearColor];
    self.facebookConfigureLabelButton = faceBookButton;
    
    UISwitch *facebookSw = [[UISwitch alloc] initWithFrame:CGRectMake(220, self.facebookTitleLabel.frame.origin.y-5, 0, 0)];
    self.facebookSwitch = facebookSw;
    
    BOOL facebook = [master.facebookSharingOn boolValue];
    if (facebook)
        [self.contentView addSubview:self.facebookSwitch];
    else {
        [self.contentView addSubview:self.facebookConfigureLabel];
        [self.contentView addSubview:self.facebookConfigureLabelButton];
    }
    
    
    //TWITTER Button
    UILabel *twConfLabel = [[UILabel alloc] initWithFrame:CGRectMake(119, self.twitterTitleLabel.frame.origin.y, 150, 21)];
    self.twitterConfigureLabel = twConfLabel;
    
    NSString *twitterConfigureLabelText;
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
    if ([twitterAccounts count] > 0)
        twitterConfigureLabelText = @"Enable";
    else
        twitterConfigureLabelText = @"No Twitter Account";

    self.twitterConfigureLabel.text = twitterConfigureLabelText;
    self.twitterConfigureLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    self.twitterConfigureLabel.backgroundColor = [UIColor clearColor];
    self.twitterTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
    self.twitterConfigureLabel.textAlignment = NSTextAlignmentRight;

    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    twitterButton.frame = self.twitterConfigureLabel.frame;
    [twitterButton addTarget:self action:@selector(twitterLabelClicked) forControlEvents:UIControlEventTouchUpInside];
    twitterButton.backgroundColor = [UIColor clearColor];
    self.twitterConfigureLabelButton = twitterButton;
    
    UISwitch *twSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, self.twitterTitleLabel.frame.origin.y-5, 0, 0)];
    self.twitterSwitch = twSwitch;
    
    BOOL twitter = [master.twitterSharingOn boolValue];
    if (twitter)
        [self.contentView addSubview:self.twitterSwitch];
    else {
        [self.contentView addSubview:self.twitterConfigureLabel];
        [self.contentView addSubview:self.twitterConfigureLabelButton];
    }
    
}

- (void)setUpViewWithShareString:(NSString *)shareString andUser:(User *)currentUser
{
    self.currentUser = currentUser;
    self.shareText = shareString;
    
    UIColor *textColor = [UIColor colorWithRed:68.0f/255.0f green:68.0f/255.0f blue:68.0f/255.0f alpha:1.0f];
    UIFont *helveticaBoldFont = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    UIFont *helveticaRegularFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    NSMutableAttributedString *fullstring = (NSMutableAttributedString *)[SDUtils attributedStringWithText:currentUser.name firstColor:textColor andSecondText:[NSString stringWithFormat:@" %@",shareString] andSecondColor:textColor andFirstFont:helveticaBoldFont andSecondFont:helveticaRegularFont];
    
//    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragrahStyle setLineSpacing:1];
//    [fullstring addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [fullstring length])];
    self.shareLabel.attributedText = fullstring;
    
    self.dateLabel.text = [SDUtils formatedLocalizedDateStringFromDate:[NSDate date]];
    
    [self.avatarImageView cancelImageRequestOperation];
    self.avatarImageView.image = nil;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:currentUser.avatarUrl]];
}

- (void)twitterLabelClicked
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    BOOL twitter = [master.twitterSharingOn boolValue];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (!twitter) {
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [store requestAccessToAccountsWithType:twitterAccountType
                                       options:nil
                                    completion:^(BOOL granted, NSError *error) {
                                        if (!granted) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                                                                    message:@"There is no permissions granted for SigningDay app to post on your behalf. You can change the permissions in Settings."
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:@"Ok"
                                                                                          otherButtonTitles:nil];
                                                [alertView show];
                                            });
                                        } else {
                                            NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                            if ([twitterAccounts count] > 0) {
                                                ACAccount *account = [twitterAccounts objectAtIndex:0];
                                                appDelegate.twitterAccount = account;
                                                master.twitterSharingOn = [NSNumber numberWithBool:YES];
                                                [context MR_saveToPersistentStoreAndWait];
                                            } else {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                                                        message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"Ok"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                });
                                            }
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self setupSocialButtons];
                                            });
                                        }
                                    }];
    }
}

- (void)facebookLabelClicked
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    BOOL facebook = [master.facebookSharingOn boolValue];
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (!facebook) {
        if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
            appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
        }
        [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            NSLog(@"FB access token: %@", appDelegate.fbSession.accessTokenData.accessToken);
            if (status == FBSessionStateOpen) {
                master.facebookSharingOn = [NSNumber numberWithBool:YES];
                
                [context MR_saveToPersistentStoreAndWait];
                [self setupSocialButtons];
            }
            
        }];
    }
}

- (IBAction)shareButtonPressed:(UIButton *)sender
{
    BOOL facebookSharingOn = NO;
    BOOL twitterSharingOn = NO;
    NSString *fullString = [NSString stringWithFormat:@"%@ %@",self.currentUser.name,self.shareText];
    
    if (self.facebookSwitch)
        facebookSharingOn = self.facebookSwitch.isOn;
    if (self.twitterSwitch)
        twitterSharingOn = self.twitterSwitch.isOn;
    
    [self.delegate shareButtonSelectedInShareView:self withShareText:fullString facebookEnabled:facebookSharingOn twitterEnabled:twitterSharingOn];
}

- (IBAction)cancelShareButtonPressed:(UIButton *)sender
{
    [self.delegate dontShareButtonSelectedInShareView:self];
}
@end
