//
//  SDUserProfileNFLPAHeaderView.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileNFLPAHeaderView.h"
#import "Member.h"
#import "NFLPA.h"
#import "AFNetworking.h"
#import "SDAPIClient.h"
#import "UIImage+Resize.h"
#import <CoreText/CoreText.h>

@interface SDUserProfileNFLPAHeaderView ()

//headerView labels
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamLabel;
@property (nonatomic, weak) IBOutlet UILabel *universityNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *positionTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearsProLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearsProTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *webSiteTitleLabel;

@property (nonatomic, strong) NSString *websiteUrl;

- (IBAction)websiteButtonPressed:(id)sender;

@end

@implementation SDUserProfileNFLPAHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupFonts];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setupFonts
{
    //since bebasneue isn't native font, we need to specify it by code
    self.teamLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.yearsProTextLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
//    self.webSiteTitleLabel.textColor = [UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]
    

    
    //    self.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.nameLabel.text = user.name;
    
    self.teamNameLabel.text = user.theNFLPA.teamName;
    self.universityNameLabel.text = user.theNFLPA.collegeName;
    
    self.positionTextLabel.text = user.theNFLPA.position;
    self.yearsProLabel.text = [NSString stringWithFormat:@"%d",[user.theNFLPA.yearsPro intValue]];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:user.theNFLPA.websiteTitle];
    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:(NSRange){0,[attString length]}];
    self.webSiteTitleLabel.attributedText = attString;
    
    if (user.theNFLPA.websiteUrl)
        self.websiteUrl = user.theNFLPA.websiteUrl;
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl
                                                  success:^(UIImage *image) {
                                                      self.userImageView.image = image;
                                                      
                                                      //delegate about data loading finish
                                                      [self.delegate dataLoadingFinishedInHeaderView:self];
                                                  }];
}

- (IBAction)websiteButtonPressed:(id)sender
{
    if (self.websiteUrl.length > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.websiteUrl]];
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
