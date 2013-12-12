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
#import "SDUtils.h"
#import "State.h"
#import "Team.h"

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
@property (nonatomic, weak) IBOutlet UIButton *highSchoolButton;
@property (weak, nonatomic) IBOutlet SDStarsRatingView *starsRatingView;
@property (weak, nonatomic) IBOutlet SDBaseScoreView *baseScoreView;

@property (nonatomic, assign) int currentHighSchoolUserId;

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
    
    self.highSchoolButton.backgroundColor = [UIColor clearColor];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.namelabel.text = user.name;
    
    NSMutableString *mutableLocationString = [[NSMutableString alloc] initWithString:@""];
    if (user.thePlayer.highSchool.theUser.name && ![user.thePlayer.highSchool.theUser.name isEqual:[NSNull null]] && user.thePlayer.highSchool.theUser.name != nil) {
        
        [mutableLocationString appendString:user.thePlayer.highSchool.theUser.name];
        if (user.thePlayer.highSchool.theUser.state && ![user.thePlayer.highSchool.theUser.state.code isEqual:[NSNull null]] && user.thePlayer.highSchool.theUser.state.code != nil) {
            [mutableLocationString appendFormat:@" (%@)",user.thePlayer.highSchool.theUser.state.code];
        }
    }
    self.schoolNamelabel.text = mutableLocationString;
    self.starsRatingView.starsCount = [user.thePlayer.starsCount intValue];
    self.baseScoreView.baseScore = [user.thePlayer.baseScore floatValue];
    self.positionNumberlabel.text = [user.thePlayer.positionRanking intValue] < 1000 ? [NSString stringWithFormat:@"%d", [user.thePlayer.positionRanking intValue]] : @"N/A";
    self.nationalNumberlabel.text = [user.thePlayer.nationalRanking intValue] < 1000 ? [NSString stringWithFormat:@"%d", [user.thePlayer.nationalRanking intValue]] : @"N/A";
    self.stateNumberlabel.text = [user.thePlayer.stateRanking intValue] < 1000 ? [NSString stringWithFormat:@"%d", [user.thePlayer.stateRanking intValue]] : @"N/A";
    self.postionAndHeightlabel.text = [NSString stringWithFormat:@"%@ %@", user.thePlayer.position, [SDUtils stringHeightFromInches:[user.thePlayer.height intValue]]];
    self.weightlabel.text = [NSString stringWithFormat:@"%d lbs",[user.thePlayer.weight intValue]];
    
    self.classNumberlabel.text = user.thePlayer.userClass;
    
    if (user.thePlayer.highSchool.theUser)
        self.currentHighSchoolUserId = [user.thePlayer.highSchool.theUser.identifier intValue];
        
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl success:^(UIImage *image) {
        self.userImageView.image = image;
        
        //delegate about data loading finish
        [self.delegate dataLoadingFinishedInHeaderView:self];
    }];
}

- (IBAction)highschoolSelected:(id)sender
{
    if (self.currentHighSchoolUserId > 0) {
        User *user = [User MR_findFirstByAttribute:@"identifier" withValue:[NSNumber numberWithInteger:self.currentHighSchoolUserId]];
        if (user)
            [self.delegate headerView:self didSelectSchoolUser:user];
    }
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
