//
//  SDLandingPagePlayerCell.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDLandingPagePlayerCell.h"
#import "User.h"
#import "State.h"
#import "Player.h"
#import "HighSchool.h"
#import "AFNetworking.h"
#import "Team.h"

@interface SDLandingPagePlayerCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *schoolLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *baseScoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *baseScoreNameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *positionNumberBackgroundImageView;


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

- (void)setupCellWithUser:(User *)user andFilteredData:(BOOL)dataIsFiltered
{    
    if (user) {

        //hiding verified image if account not verified, hide position view if list is filtered
        if (self.accountVerifiedImageView) {
            self.accountVerifiedImageView.hidden = ([user.accountVerified boolValue]) ? NO : YES;
        }
        
        self.positionNumberBackgroundImageView.hidden = (dataIsFiltered) ? YES : NO;
        
        self.nameLabel.text = user.name;
        
        NSMutableString *playerLocationString = [[NSMutableString alloc] initWithString:@""];
        
        if ([user.thePlayer.highSchool.theUser.name class] != [NSNull null] && user.thePlayer.highSchool.theUser.name != nil)
            [playerLocationString appendString:user.thePlayer.highSchool.theUser.name];
        if ([user.thePlayer.highSchool.theUser.state.code class] != [NSNull null] && user.thePlayer.highSchool.theUser.state.code != nil)
            [playerLocationString appendFormat:@" (%@)",user.thePlayer.highSchool.theUser.state.code];
        
        self.schoolLabel.text = playerLocationString;
        self.baseScoreNameLabel.text = [NSString stringWithFormat:@"%.2f",[user.thePlayer.baseScore floatValue]];
        
        //playing position E.g "CB"
        self.positionNameLabel.text = user.thePlayer.position;
        self.yearNameLabel.text = user.thePlayer.userClass;
        
        //cancel previous requests and set user image
        [self.userImageView cancelImageRequestOperation];
        self.userImageView.image = nil;
        [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    }
}


@end
