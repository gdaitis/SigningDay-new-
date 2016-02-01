//
//  SDUserProfileOrganizationHeaderView.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 1/28/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDUserProfileOrganizationHeaderView.h"
#import "Organization.h"
#import "AFNetworking.h"
#import "SDAPIClient.h"
#import "UIImage+Resize.h"

@interface SDUserProfileOrganizationHeaderView ()

//headerView labels
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *founderLabel;
@property (nonatomic, weak) IBOutlet UILabel *founderNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@end

@implementation SDUserProfileOrganizationHeaderView

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
    self.founderLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    self.founderNameLabel.font = [UIFont fontWithName:@"BebasNeue" size:15.0];
    
//    self.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
}

- (void)setupInfoWithUser:(User *)user
{
    [super setupInfoWithUser:user];
    
    self.nameLabel.text = user.name;
    self.founderNameLabel.text = user.theOrganization.coFounder;
    
    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];
    NSURLRequest *userAvatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
    AFImageRequestOperation *userAvatarOperation = [AFImageRequestOperation imageRequestOperationWithRequest:userAvatarRequest
                                                                                                     success:^(UIImage *image) {
                                                                                                         self.userImageView.image = image;
                                                                                                     }];
    [operationsArray addObject:userAvatarOperation];
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
