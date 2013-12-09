//
//  SDUserProfileSlidingButtonView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDUserProfileSlidingButtonView.h"
#import "UIView+NibLoading.h"
#import <QuartzCore/QuartzCore.h>
#import "SDProfileButtonsView.h"
#import "NSObject+MasterUserMethods.h"
#import "User.h"

@interface SDUserProfileSlidingButtonView () <SDProfileButtonsViewDelegate>

@property (nonatomic, weak) CAGradientLayer *shadowLayer;

@property (nonatomic, weak) IBOutlet UILabel *followersTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingTitleLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation SDUserProfileSlidingButtonView


#pragma mark - initializers

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder
{
    if ([[self subviews] count] == 0) {
        SDUserProfileSlidingButtonView* theRealThing = (id)[SDUserProfileSlidingButtonView loadInstanceFromNib];
        theRealThing.frame = self.frame;
        theRealThing.autoresizingMask = self.autoresizingMask;
        theRealThing.alpha = self.alpha;
        
        
        return theRealThing;
    }
    return self;
}

#pragma mark - View setup

- (void)layoutSubviews
{
    [self setupView];
    
    UIView *lineView = [self.bottomView viewWithTag:999];
    if (lineView) {
        [lineView removeFromSuperview];
    }
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bottomView.frame.size.width, 1)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    bottomLineView.tag = 999;
    [self.bottomView addSubview:bottomLineView];
    
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    
    if (!self.shadowLayer) {
        CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
        float y = 0;
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
//            y = 20;
        newShadow.frame = CGRectMake(0, 1 + y, self.bottomView.frame.size.width, 4);
        newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
        self.shadowLayer = newShadow;
        [self.bottomView.layer addSublayer:self.shadowLayer];
    }
    
    [super layoutSubviews];
}

- (void)setupView
{
    SDProfileButtonsView *profileButtonsView = [[SDProfileButtonsView alloc] init];
    NSArray *profileButtonsArray = [[NSArray alloc] init];
    BOOL masterIsCoach = NO;
    User *masterUser = [self getMasterUser];
    if ([masterUser.userTypeId intValue] == SDUserTypeCoach)
        masterIsCoach = YES;
    
    switch (self.userType) {
        case SDUserTypePlayer:
            if (masterIsCoach)
                profileButtonsArray = @[[NSNumber numberWithInt:SDProfileButtonTypeContacts],
                                        [NSNumber numberWithInt:SDProfileButtonTypeKeyAttributes],
                                        [NSNumber numberWithInt:SDProfileButtonTypeOffers],
                                        [NSNumber numberWithInt:SDProfileButtonTypePhotos],
                                        [NSNumber numberWithInt:SDProfileButtonTypeVideos],
                                        [NSNumber numberWithInt:SDProfileButtonTypeBio]];
            else
                profileButtonsArray = @[[NSNumber numberWithInt:SDProfileButtonTypeKeyAttributes],
                                        [NSNumber numberWithInt:SDProfileButtonTypeOffers],
                                        [NSNumber numberWithInt:SDProfileButtonTypePhotos],
                                        [NSNumber numberWithInt:SDProfileButtonTypeVideos],
                                        [NSNumber numberWithInt:SDProfileButtonTypeBio]];
            break;
        case SDUserTypeHighSchool:
            profileButtonsArray = @[[NSNumber numberWithInt:SDProfileButtonTypeRoster],
                                    [NSNumber numberWithInt:SDProfileButtonTypePhotos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeVideos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeBio]];
            break;
        case SDUserTypeTeam:
            profileButtonsArray = @[[NSNumber numberWithInt:SDProfileButtonTypeCommits],
                                    [NSNumber numberWithInt:SDProfileButtonTypeStaff],
                                    [NSNumber numberWithInt:SDProfileButtonTypePhotos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeVideos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeBio]];
            break;
        case SDUserTypeMember:
            profileButtonsArray = @[[NSNumber numberWithInt:SDProfileButtonTypePhotos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeVideos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeBio]];
            break;
        case SDUserTypeCoach:
            profileButtonsArray = @[[NSNumber numberWithInt:SDProfileButtonTypePhotos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeVideos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeBio]];
            break;
        case SDUserTypeNFLPA:
            profileButtonsArray = @[[NSNumber numberWithInt:SDProfileButtonTypePhotos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeVideos],
                                    [NSNumber numberWithInt:SDProfileButtonTypeBio]];
            break;
            
        default:
            break;
    }
    profileButtonsView.arrayOfButtonTypeNumberObjects = profileButtonsArray;
    profileButtonsView.delegate = self;
    
    self.scrollView.contentSize = profileButtonsView.frame.size;
    [self.scrollView addSubview:profileButtonsView];
    
    self.followersCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:11.0];
    self.followingCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:11.0];
}

#pragma mark - Follow button presses

- (void)followButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    [self.delegate userProfileSlidingButtonView:self
                                 isNowFollowing:sender.selected];
}

#pragma mark - SDProfileButtonsViewDelegate methods

- (void)profileButtonsViewKeyAttributesPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate keyAttributesPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewOffersPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate offersPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewRosterPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate rosterPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewCommitsPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate commitsPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewStaffPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate staffButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewPhotosPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate photosButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewVideosPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate videosButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewBioPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate bioButtonPressedInUserProfileSlidingButtonView:self];
}

- (void)profileButtonsViewContactsPressed:(SDProfileButtonsView *)profileButtonsView
{
    [self.delegate contactsPressedInUserProfileSlidingButtonView:self];
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
