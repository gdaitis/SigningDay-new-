//
//  SDUserProfileNFLPAHeaderView.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileOrganizationMemeberHeaderView.h"
#import "Member.h"
#import "OrganizationMemeber.h"
#import "AFNetworking.h"
#import "SDAPIClient.h"
#import "UIImage+Resize.h"
#import <CoreText/CoreText.h>

@interface SDUserProfileOrganizationMemeberHeaderView ()

//headerView labels
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamLabel;
@property (nonatomic, weak) IBOutlet UILabel *universityNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *positionTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearsProLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearsProTextLabel;

@end

@implementation SDUserProfileOrganizationMemeberHeaderView

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
    self.positionLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.nameLabel.text = user.name;
    
    self.teamNameLabel.text = user.theOrganizationMember.teamName;
    self.universityNameLabel.text = user.theOrganizationMember.collegeName;
    
    self.positionTextLabel.text = user.theOrganizationMember.position;
    self.yearsProLabel.text = ([user.theOrganizationMember.yearsPro intValue] > 0) ? [NSString stringWithFormat:@"%d",[user.theOrganizationMember.yearsPro intValue]] : @"N/A";
    
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl
                                                  success:^(UIImage *image) {
                                                      self.userImageView.image = image;
                                                      
                                                      //delegate about data loading finish
                                                      [self.delegate dataLoadingFinishedInHeaderView:self];
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
