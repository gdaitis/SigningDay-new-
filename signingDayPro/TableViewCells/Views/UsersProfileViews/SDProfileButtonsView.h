//
//  SDProfileButtonsView.h
//  SigningDay
//
//  Created by lite on 06/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SDProfileButtonTypeKeyAttributes,
    SDProfileButtonTypeOffers,
    SDProfileButtonTypeRoster,
    SDProfileButtonTypeCommits,
    SDProfileButtonTypeStaff,
    SDProfileButtonTypePhotos,
    SDProfileButtonTypeVideos,
    SDProfileButtonTypeBio,
    SDProfileButtonTypeContacts
} SDProfileButtonType;

@class SDProfileButtonsView;

@protocol SDProfileButtonsViewDelegate <NSObject>

@optional

- (void)profileButtonsViewKeyAttributesPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewOffersPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewRosterPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewCommitsPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewStaffPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewPhotosPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewVideosPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewBioPressed:(SDProfileButtonsView *)profileButtonsView;
- (void)profileButtonsViewContactsPressed:(SDProfileButtonsView *)profileButtonsView;

@end

@interface SDProfileButtonsView : UIView

@property (nonatomic, strong) NSArray *arrayOfButtonTypeNumberObjects;
@property (nonatomic, weak) id <SDProfileButtonsViewDelegate> delegate;

@end
