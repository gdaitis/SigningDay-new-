//
//  SDUserProfileTeamHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileTeamHeaderView.h"

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
    _headCoachLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _conferenceRankingLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
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
