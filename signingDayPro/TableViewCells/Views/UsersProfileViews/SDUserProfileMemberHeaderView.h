//
//  SDUserProfileHeaderView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDUserProfileSlidingButtonView.h"
#import "SDBuzzButtonView.h"

@class User;

@interface SDUserProfileMemberHeaderView : UIView <SDBuzzButtonViewDelegate>

@property (nonatomic, strong) IBOutlet SDUserProfileSlidingButtonView *slidingButtonView;
@property (nonatomic, strong) IBOutlet SDBuzzButtonView *buzzButtonView;

//headerView labels
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *profileTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *favoriteTeamLabel;
@property (nonatomic, weak) IBOutlet UIImageView *favoriteTeamImageView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *memberSinceLabel;
@property (nonatomic, weak) IBOutlet UILabel *memberSinceDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *postsLabel;
@property (nonatomic, weak) IBOutlet UILabel *postsCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *uploadsLabel;
@property (nonatomic, weak) IBOutlet UILabel *uploadsCountLabel;


- (void)setupInfoWithUser:(User *)user;


@end
