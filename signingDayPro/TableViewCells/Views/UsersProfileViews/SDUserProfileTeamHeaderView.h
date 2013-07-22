//
//  SDUserProfileTeamHeaderView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDUserProfileTeamHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *universityLabel;
@property (nonatomic, weak) IBOutlet UILabel *conferenceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *conferenceImageView;

@property (nonatomic, weak) IBOutlet UILabel *conferenceRankingLabel;
@property (nonatomic, weak) IBOutlet UILabel *conferenceRankingNumberLabel;

@property (nonatomic, weak) IBOutlet UILabel *headCoachLabel;
@property (nonatomic, weak) IBOutlet UILabel *headCoachNameLabel;
@end
