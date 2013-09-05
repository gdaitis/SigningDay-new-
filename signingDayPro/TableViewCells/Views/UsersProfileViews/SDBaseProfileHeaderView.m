//
//  SDBaseProfileHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseProfileHeaderView.h"
#import "UIView+NibLoading.h"
#import "User.h"
#import "Master.h"

@interface SDBaseProfileHeaderView ()

@property (nonatomic, strong) User *user;

@end

@implementation SDBaseProfileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)hideBuzzButtonView:(BOOL)hide
{
    if (hide) {
        _buzzButtonView.hidden = YES;
        CGRect frame = self.frame;
        frame.size.height = self.slidingButtonView.frame.origin.y + self.slidingButtonView.frame.size.height;
        self.frame = frame;
    }
    else {
        _buzzButtonView.hidden = NO;
        CGRect frame = self.frame;
        frame.size.height = self.buzzButtonView.frame.origin.y + self.buzzButtonView.frame.size.height;
        self.frame = frame;
    }
}

- (void)setupInfoWithUser:(User *)user
{
    self.user = user;
    
    self.slidingButtonView.followersCountLabel.text = [NSString stringWithFormat:@"%d", [user.numberOfFollowers intValue]];
    self.slidingButtonView.followingCountLabel.text = [NSString stringWithFormat:@"%d", [user.numberOfFollowing intValue]];
    
    [self updateFollowingInfo];
}

- (void)updateFollowingInfo
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username"
                                           withValue:username
                                           inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    if ([self.user.followedBy isEqual:master])
        self.slidingButtonView.followButton.selected = YES;
    else
        self.slidingButtonView.followButton.selected = NO;
}
@end
