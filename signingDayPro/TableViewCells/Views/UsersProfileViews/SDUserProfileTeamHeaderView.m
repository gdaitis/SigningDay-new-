//
//  SDUserProfileTeamHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileTeamHeaderView.h"
#import "Team.h"
#import "Coach.h"
#import "Player.h"
#import "User.h"
#import "AFNetworking.h"
#import "SDAPIClient.h"
#import "UIImage+Resize.h"

@interface SDUserProfileTeamHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *universityLabel;
@property (nonatomic, weak) IBOutlet UILabel *conferenceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *conferenceImageView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@property (nonatomic, weak) IBOutlet UILabel *conferenceRankingLabel;
@property (nonatomic, weak) IBOutlet UILabel *conferenceRankingNumberLabel;

@property (nonatomic, weak) IBOutlet UILabel *headCoachLabel;
@property (nonatomic, weak) IBOutlet UILabel *headCoachNameLabel;

@end

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
    self.conferenceLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.conferenceRankingLabel.text = @"CONFERENCE RANKING:";
    self.headCoachLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.conferenceRankingLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.nameLabel.text = user.name;
    self.universityLabel.text = user.theTeam.locationExtended;
    self.conferenceRankingNumberLabel.text = user.theTeam.conferenceRankingString;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coachLevel == %@", [NSNumber numberWithInt:1]];
    NSArray *array = [[user.theTeam.headCoaches allObjects] filteredArrayUsingPredicate:predicate];
    
    self.headCoachNameLabel.text = @"";
    if ([array count] > 0) {
        NSMutableString *string = [[NSMutableString alloc] init];
        
        for (int i = 0; i < [array count]; i++) {
            Coach *coach = [array objectAtIndex:i];
            [string appendString:coach.theUser.name];
            if (i+1 != [array count]) {
                [string appendString:@", "];
            }
        }
        self.headCoachNameLabel.text = string;
    }
    
    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];
    NSURLRequest *userAvatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
    AFImageRequestOperation *userAvatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:userAvatarRequest
                                                                                                     success:^(UIImage *image) {
                                                                                                         self.userImageView.image = image;
                                                                                                     }];
    [operationsArray addObject:userAvatarOperation];
    
    NSString *logoUrl;
    if (![user.theTeam.conferenceLogoUrlBlack isEqual:@""])
        logoUrl = user.theTeam.conferenceLogoUrlBlack;
    else
        logoUrl = user.theTeam.conferenceLogoUrl;
    NSURLRequest *conferenceAvatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:logoUrl]];
    AFImageRequestOperation *conferenceAvatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:conferenceAvatarRequest
                                                                                                          success:^(UIImage *image) {
                                                                                                              
                                                                                                              self.conferenceImageView.image = [image resizeImage:image withWidth:self.conferenceImageView.frame.size.width withHeight:self.conferenceImageView.frame.size.height];
                                                                                                          }];
    [operationsArray addObject:conferenceAvatarOperation];
    [[SDAPIClient sharedClient] enqueueBatchOfHTTPRequestOperations:operationsArray
                                                      progressBlock:nil
                                                    completionBlock:^(NSArray *operations) {
                                                        [self.delegate dataLoadingFinishedInHeaderView:self];
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
