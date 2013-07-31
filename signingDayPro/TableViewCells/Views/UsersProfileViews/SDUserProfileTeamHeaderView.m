//
//  SDUserProfileTeamHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileTeamHeaderView.h"

@interface SDUserProfileTeamHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *universityLabel;
@property (nonatomic, weak) IBOutlet UILabel *conferenceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *conferenceImageView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@property (nonatomic, weak) IBOutlet UILabel *conferenceRankingLabel;
@property (nonatomic, weak) IBOutlet UILabel *conferenceRankingNumberLabel;

@property (nonatomic, weak) IBOutlet UILabel *headCoachLabel;
@property (nonatomic, weak) IBOutlet UILabel *headCoachNameLabel;

@end

@implementation SDUserProfileTeamHeaderView

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
    _conferenceLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _conferenceRankingLabel.text = @"CONFERENCE RANKING:";
    _headCoachLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _conferenceRankingLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    _nameLabel.text = user.name;
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl success:^(UIImage *image) {
        _conferenceImageView.image = image;
        _userImageView.image = image;
        
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
