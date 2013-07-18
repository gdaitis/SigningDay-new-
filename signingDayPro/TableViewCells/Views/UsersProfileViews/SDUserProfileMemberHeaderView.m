//
//  SDUserProfileHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileMemberHeaderView.h"
#import "User.h"
#import "SDUserProfileSlidingButtonView.h"
#import "SDImageService.h"

@implementation SDUserProfileMemberHeaderView

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
    _favoriteTeamLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _memberSinceLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _postsLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    _uploadsLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
}

- (void)setupInfoWithUser:(User *)user
{
    _nameLabel.text = user.name;
    
    [[SDImageService sharedService] getImageWithURLString:user.avatarUrl success:^(UIImage *image) {
        _userImageView.image = image;
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
