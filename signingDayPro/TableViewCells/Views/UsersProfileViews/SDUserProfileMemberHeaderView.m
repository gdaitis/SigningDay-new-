//
//  SDUserProfileHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileMemberHeaderView.h"
#import "Member.h"
#import "Team.h"
#import "AFNetworking.h"
#import "SDAPIClient.h"
#import "UIImage+Resize.h"

@interface SDUserProfileMemberHeaderView ()

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

@end

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
    self.favoriteTeamLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.memberSinceLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.postsLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.uploadsLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    
//    self.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.nameLabel.text = user.name;
    self.profileTypeLabel.text = @"Member";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = usLocale;
    NSString *memberSinceString = [dateFormatter stringFromDate:user.theMember.memberSince];
    self.memberSinceDateLabel.text = memberSinceString;
    
    self.postsCountLabel.text = [NSString stringWithFormat:@"%d", [user.theMember.postsCount intValue]];
    self.uploadsCountLabel.text = [NSString stringWithFormat:@"%d", [user.theMember.uploadsCount intValue]];
    
    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];
    NSURLRequest *userAvatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
    AFImageRequestOperation *userAvatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:userAvatarRequest
                                                                                                     success:^(UIImage *image) {
                                                                                                         self.userImageView.image = image;
                                                                                                     }];
    [operationsArray addObject:userAvatarOperation];
    NSURLRequest *favoriteTeamAvatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:user.theMember.favoriteTeam.theUser.avatarUrl]];
    AFImageRequestOperation *favoriteTeamAvatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:favoriteTeamAvatarRequest
                                                                                                             success:^(UIImage *image) {
                                                                                                                 
                                                                                                                 self.favoriteTeamImageView.image = [image resizeImage:image withWidth:self.favoriteTeamImageView.frame.size.width withHeight:self.favoriteTeamImageView.frame.size.height];
                                                                                                             }];
    [operationsArray addObject:favoriteTeamAvatarOperation];
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
