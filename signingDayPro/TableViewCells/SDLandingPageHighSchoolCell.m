//
//  SDLandingPageHighSchoolCell.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/5/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDLandingPageHighSchoolCell.h"
#import "User.h"
#import "Player.h"
#import "HighSchool.h"
#import "AFNetworking.h"

@interface SDLandingPageHighSchoolCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@property (nonatomic, weak) IBOutlet UILabel *totalPospectsLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalPospectsNameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *accountVerifiedImageView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIImageView *positionNumberBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *userPositionLabel;

@end

@implementation SDLandingPageHighSchoolCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialSetup];
}

- (void)initialSetup
{
    self.positionNumberBackgroundImageView.image = [[UIImage imageNamed:@"PlayerCellStrechableNumberImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.userPositionLabel.font = [UIFont fontWithName:@"BebasNeue" size:14];
    self.totalPospectsLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
    self.totalPospectsNameLabel.font = [UIFont fontWithName:@"BebasNeue" size:15];
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
//        self.totalPospectsNameLabel.text = user.theHighSchool.prospects;
        
        //cancel previous requests and set user image
        [self.userImageView cancelImageRequestOperation];
        self.userImageView.image = nil;
        [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    }
}

@end
