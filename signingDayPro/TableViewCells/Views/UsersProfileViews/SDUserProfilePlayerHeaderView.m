//
//  SDUserProfilePlayerHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfilePlayerHeaderView.h"
#import "User.h"
#import "SDImageService.h"
#import "SDStarsRatingView.h"
#import "SDBaseScoreView.h"

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
    _baseScorelabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _rankingslabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _infolabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
}

- (void)setupInfoWithUser:(User *)user
{
    _namelabel.text = user.name;
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl success:^(UIImage *image) {
        _userImageView.image = image;
#warning hardcoded for testing
        self.starsRatingView.starsCount = 4;
        self.baseScoreView.baseScore = 87.69;
    }];
}

- (void)hideBuzzButtonView:(BOOL)hide
{
    if (hide) {
        _buzzButtonView.hidden = YES;
    }
    else {
        _buzzButtonView.hidden = NO;
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
