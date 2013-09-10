//
//  SDLandingPageCollegeCell.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/5/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDLandingPageCollegeCell.h"
#import "User.h"
#import "Team.h"
#import "HighSchool.h"
#import "AFNetworking.h"


@interface SDLandingPageCollegeCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *commitsLabel;
@property (nonatomic, weak) IBOutlet UILabel *commitsNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalScoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalScoreNameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *accountVerifiedImageView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIImageView *positionNumberBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *playerPositionLabel;

@end

@implementation SDLandingPageCollegeCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialSetup];
}

- (void)initialSetup
{
    self.positionNumberBackgroundImageView.image = [[UIImage imageNamed:@"PlayerCellStrechableNumberImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.playerPositionLabel.font = [UIFont fontWithName:@"BebasNeue" size:14];
    self.commitsLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.commitsNameLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.totalScoreLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.totalScoreNameLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
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
    if (user) {
        
        if ([user.accountVerified boolValue]) {
            self.accountVerifiedImageView.hidden = NO;
        }
        else {
            self.accountVerifiedImageView.hidden = YES;
        }
        self.nameLabel.text = user.name;

//        self.commitsNameLabel =  user.theTeam.commited;
//        self.totalScoreNameLabel user.theTeam.totalScore;
        
        //cancel previous requests and set user image
        [self.userImageView cancelImageRequestOperation];
        [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    }
}

@end
