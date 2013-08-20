//
//  SDUserProfilePlayerHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfilePlayerHeaderView.h"
#import "SDStarsRatingView.h"
#import "SDBaseScoreView.h"
#import "Player.h"
#import "HighSchool.h"
#import "User.h"

@interface SDUserProfilePlayerHeaderView ()

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *namelabel;
@property (nonatomic, weak) IBOutlet UILabel *schoolNamelabel;
@property (nonatomic, weak) IBOutlet UILabel *baseScorelabel;
@property (nonatomic, weak) IBOutlet UILabel *rankingslabel;
@property (nonatomic, weak) IBOutlet UILabel *infolabel;
@property (nonatomic, weak) IBOutlet UILabel *positionlabel;
@property (nonatomic, weak) IBOutlet UILabel *positionNumberlabel;
@property (nonatomic, weak) IBOutlet UILabel *nationallabel;
@property (nonatomic, weak) IBOutlet UILabel *nationalNumberlabel;
@property (nonatomic, weak) IBOutlet UILabel *statelabel;
@property (nonatomic, weak) IBOutlet UILabel *stateNumberlabel;
@property (nonatomic, weak) IBOutlet UILabel *postionAndHeightlabel;
@property (nonatomic, weak) IBOutlet UILabel *weightlabel;
@property (nonatomic, weak) IBOutlet UILabel *classlabel;
@property (nonatomic, weak) IBOutlet UILabel *classNumberlabel;
@property (weak, nonatomic) IBOutlet SDStarsRatingView *starsRatingView;
@property (weak, nonatomic) IBOutlet SDBaseScoreView *baseScoreView;

@end

@implementation SDUserProfilePlayerHeaderView

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
    self.baseScorelabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.rankingslabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.infolabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.namelabel.text = user.name;
    self.schoolNamelabel.text = user.thePlayer.highSchool.theUser.name;
    self.starsRatingView.starsCount = [user.thePlayer.starsCount intValue];
    self.baseScoreView.baseScore = [user.thePlayer.baseScore floatValue];
    self.positionNumberlabel.text = [NSString stringWithFormat:@"%d", [user.thePlayer.positionRanking intValue]];
    self.nationalNumberlabel.text = [NSString stringWithFormat:@"%d", [user.thePlayer.nationalRanking intValue]];
    self.stateNumberlabel.text = [NSString stringWithFormat:@"%d", [user.thePlayer.stateRanking intValue]];
    #warning height in inches
    self.postionAndHeightlabel.text = [NSString stringWithFormat:@"%@ %d", user.thePlayer.position, [user.thePlayer.height intValue]];
    self.classNumberlabel.text = user.thePlayer.userClass;
    
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl success:^(UIImage *image) {
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
