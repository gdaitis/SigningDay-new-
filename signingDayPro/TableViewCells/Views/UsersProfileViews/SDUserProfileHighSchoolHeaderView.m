//
//  SDUserProfileHighSchoolHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 8/7/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileHighSchoolHeaderView.h"
#import "HighSchool.h"

@interface SDUserProfileHighSchoolHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *mascotLabel;
@property (nonatomic, weak) IBOutlet UILabel *headCoachLabel;
@property (nonatomic, weak) IBOutlet UILabel *headCoachNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@end

@implementation SDUserProfileHighSchoolHeaderView


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
    self.headCoachLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.addressLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    
    //    self.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.nameLabel.text = user.name;
    self.mascotLabel.text = [NSString stringWithFormat:@"Mascot: %@", user.theHighSchool.mascot];
    self.headCoachNameLabel.text = user.theHighSchool.headCoachName;
    self.addressNameLabel.text = user.theHighSchool.address;
    
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl
                                                  success:^(UIImage *image) {
        self.userImageView.image = image;
        
        //delegate about data loading finish
        [self.delegate dataLoadingFinishedInHeaderView:self];
    }];
}


@end
