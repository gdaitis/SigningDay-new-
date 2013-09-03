//
//  SDLandingPagePlayerCell.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDLandingPagePlayerCell.h"
#import "User.h"
#import "Player.h"
#import "HighSchool.h"
#import "AFNetworking.h"

@interface SDLandingPagePlayerCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *schoolLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *baseScoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *baseScoreNameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIImageView *positionNumberBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *playerPositionLabel;

@end

@implementation SDLandingPagePlayerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialSetup];
}

- (void)initialSetup
{
    self.positionNumberBackgroundImageView.image = [[UIImage imageNamed:@"PlayerCellStrechableNumberImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.playerPositionLabel.font = [UIFont fontWithName:@"BebasNeue" size:14];
    self.positionLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.yearLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.baseScoreLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.positionNameLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.yearNameLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.baseScoreNameLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Cell setup

- (void)setupCellWithUser:(User *)user
{
    [self.playerPositionLabel updateConstraints];
    
    if (user) {
        self.nameLabel.text = user.name;
        self.schoolLabel.text = user.thePlayer.highSchool.theUser.name;
        self.baseScoreNameLabel = [NSString stringWithFormat:@"%f",[user.thePlayer.baseScore floatValue]];
        
        //position in list number
        self.playerPositionLabel = [NSString stringWithFormat:@"%d",[user.thePlayer.nationalRanking intValue]];
        
        //playing position E.g "CB"
        self.positionNameLabel.text = user.thePlayer.position;
        self.yearNameLabel.text = user.thePlayer.userClass;
        
        //cancel previous requests and set user image
        [self.userImageView cancelImageRequestOperation];
        [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    }
}


@end
