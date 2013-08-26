//
//  SDUserProfileCoachHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileCoachHeaderView.h"
#import "Coach.h"
#import "Team.h"
#import "User.h"
#import "AFNetworking.h"
#import "SDAPIClient.h"
#import "UIImage+Resize.h"

@interface SDUserProfileCoachHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamLabel;
@property (nonatomic, weak) IBOutlet UIImageView *teamImageView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@property (nonatomic, weak) IBOutlet UILabel *positionLabel;
@property (nonatomic, weak) IBOutlet UILabel *positionNameLabel;

@end

@implementation SDUserProfileCoachHeaderView

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
    self.teamLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.positionLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.nameLabel.text = user.name;
    self.cityLabel.text = user.theCoach.location;
    self.positionNameLabel.text = user.theCoach.position;
    
    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];
    NSURLRequest *userAvatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
    AFImageRequestOperation *userAvatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:userAvatarRequest
                                                                                                     success:^(UIImage *image) {
                                                                                                         self.userImageView.image = image;
                                                                                                     }];
    [operationsArray addObject:userAvatarOperation];
    NSURLRequest *teamAvatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:user.theCoach.team.theUser.avatarUrl]];
    AFImageRequestOperation *teamAvatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:teamAvatarRequest
                                                                                                     success:^(UIImage *image) {
                                                                                                         
                                                                                                         self.teamImageView.image = [image resizeImage:image withWidth:self.teamImageView.frame.size.width withHeight:self.teamImageView.frame.size.height];
                                                                                                     }];
    [operationsArray addObject:teamAvatarOperation];
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
