//
//  SDProfileButtonsView.m
//  SigningDay
//
//  Created by lite on 06/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#define kSDProfileButtonsViewDefaultHeight 80
#define kSDProfileButtonsViewDefaultWidth 320

#define kSDProfileButtonsViewWidthOfButtonAndLabelView 77
#define kSDProfileButtonsViewHeightOfButtonImage 45
#define kSDProfileButtonsViewHeightOfButtonLabel 13
#define kSDProfileButtonsViewButtonImageBottomPadding 3

#define kSDProfileButtonsViewLeftRightPadding 9
#define kSDProfileButtonsViewHorizontalPadding 14

#import "SDProfileButtonsView.h"

@interface SDProfileButtonsView ()

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation SDProfileButtonsView

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0,
                                0,
                                kSDProfileButtonsViewDefaultWidth,
                                kSDProfileButtonsViewDefaultHeight);
    }
    return self;
}

- (void)setArrayOfButtonTypeNumberObjects:(NSArray *)arrayOfButtonTypeNumberObjects
{
    int countOfButtons = arrayOfButtonTypeNumberObjects.count;
    
    BOOL needsMoreWidth;
    
    float numberOfButtonsFittingIntoCurrentFrame = self.frame.size.width / kSDProfileButtonsViewWidthOfButtonAndLabelView;
    if (numberOfButtonsFittingIntoCurrentFrame < countOfButtons)
        needsMoreWidth = YES;
    else
        needsMoreWidth = NO;
    
    if (needsMoreWidth) {
        CGRect mainFrame = self.frame;
        mainFrame.size.width = 2 * kSDProfileButtonsViewLeftRightPadding + countOfButtons * kSDProfileButtonsViewWidthOfButtonAndLabelView + (countOfButtons - 1) * kSDProfileButtonsViewHorizontalPadding;
        self.frame = mainFrame;
        
        [self layoutButtonsWithButtonTypesArray:arrayOfButtonTypeNumberObjects
                                     andOriginX:kSDProfileButtonsViewLeftRightPadding];
    } else {
        int originX = (self.frame.size.width - (countOfButtons * kSDProfileButtonsViewWidthOfButtonAndLabelView + (countOfButtons - 1) * kSDProfileButtonsViewHorizontalPadding)) / 2;
        [self layoutButtonsWithButtonTypesArray:arrayOfButtonTypeNumberObjects
                                     andOriginX:originX];
    }
    
    _arrayOfButtonTypeNumberObjects = arrayOfButtonTypeNumberObjects;
}

- (void)layoutButtonsWithButtonTypesArray:(NSArray *)buttonTypesArray
                               andOriginX:(CGFloat)originX
{
    for (int i = 0; i < buttonTypesArray.count; i++) {
        NSNumber *buttonTypeNumber = [buttonTypesArray objectAtIndex:i];
        SDProfileButtonType buttonType = [buttonTypeNumber intValue];
        UIView *buttonAndLabelView = [self buttonAndLabelViewFotButtonType:buttonType];
        CGRect frame = buttonAndLabelView.frame;
        frame.origin.y = 11;
        frame.origin.x = originX + i * (kSDProfileButtonsViewWidthOfButtonAndLabelView + kSDProfileButtonsViewHorizontalPadding);
        buttonAndLabelView.frame = frame;
        [self addSubview:buttonAndLabelView];
    }
}

- (UIView *)buttonAndLabelViewFotButtonType:(SDProfileButtonType)profileButtonType
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            kSDProfileButtonsViewWidthOfButtonAndLabelView,
                                                            kSDProfileButtonsViewHeightOfButtonImage + kSDProfileButtonsViewButtonImageBottomPadding + kSDProfileButtonsViewHeightOfButtonLabel)];
    UIImage *buttonImage = [self imageForProfileButtonType:profileButtonType];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,
                              0,
                              kSDProfileButtonsViewWidthOfButtonAndLabelView,
                              kSDProfileButtonsViewHeightOfButtonImage);
    [button setBackgroundImage:buttonImage
                      forState:UIControlStateNormal];
    
    SEL selector = NULL;
    
    switch (profileButtonType) {
        case SDProfileButtonTypeKeyAttributes:
            selector = @selector(keyAttributesPressed);
            break;
            
        case SDProfileButtonTypeOffers:
            selector = @selector(offersPressed);
            break;
            
        case SDProfileButtonTypeRoster:
            selector = @selector(rosterPressed);
            break;
            
        case SDProfileButtonTypeCommits:
            selector = @selector(commitsPressed);
            break;
            
        case SDProfileButtonTypeStaff:
            selector = @selector(staffPressed);
            break;
            
        case SDProfileButtonTypePhotos:
            selector = @selector(photosPressed);
            break;
            
        case SDProfileButtonTypeVideos:
            selector = @selector(videosPressed);
            break;
            
        case SDProfileButtonTypeBio:
            selector = @selector(bioPressed);
            break;
            
        case SDProfileButtonTypeContacts:
            selector = @selector(contactsPressed);
            break;
        case SDProfileButtonTypeTopSchools:
            selector = @selector(topSchoolsPressed);
            break;
            
        default:
            break;
    }
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               kSDProfileButtonsViewHeightOfButtonImage + kSDProfileButtonsViewButtonImageBottomPadding,
                                                               kSDProfileButtonsViewWidthOfButtonAndLabelView,
                                                               kSDProfileButtonsViewHeightOfButtonLabel)];
    label.font = [UIFont fontWithName:@"Helvetica Bold"
                                 size:11];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self textForProfileButtonType:profileButtonType];
    
    [view addSubview:label];
    
    return view;
}

- (NSString *)textForProfileButtonType:(SDProfileButtonType)profileButtonType
{
    NSString *text = nil;
    
    switch (profileButtonType) {
        case SDProfileButtonTypeKeyAttributes:
            text = @"Key Attributes";
            break;
            
        case SDProfileButtonTypeOffers:
            text = @"Offers";
            break;
            
        case SDProfileButtonTypeRoster:
            text = @"Roster";
            break;
            
        case SDProfileButtonTypeCommits:
            text = @"Commits";
            break;
            
        case SDProfileButtonTypeStaff:
            text = @"Staff";
            break;
            
        case SDProfileButtonTypePhotos:
            text = @"Photos";
            break;
            
        case SDProfileButtonTypeVideos:
            text = @"Videos";
            break;
            
        case SDProfileButtonTypeBio:
            text = @"Bio";
            break;
            
        case SDProfileButtonTypeContacts:
            text = @"Contacts";
            break;
        case SDProfileButtonTypeTopSchools:
            text = @"Top Schools";
            break;
            
        default:
            break;
    }
    
    return text;
}

- (UIImage *)imageForProfileButtonType:(SDProfileButtonType)profileButtonType
{
    UIImage *image = nil;
    switch (profileButtonType) {
        case SDProfileButtonTypeKeyAttributes:
            image = [UIImage imageNamed:@"UserProfileKeyAttributesButton.png"];
            break;
            
        case SDProfileButtonTypeOffers:
            image = [UIImage imageNamed:@"OffersButtonImage.png"];
            break;
            
        case SDProfileButtonTypeRoster:
            image = [UIImage imageNamed:@"UserProfileProspectsButton.png"];
            break;
        
        case SDProfileButtonTypeCommits:
            image = [UIImage imageNamed:@"UserProfileCommitsButton.png"];
            break;
            
        case SDProfileButtonTypeStaff:
            image = [UIImage imageNamed:@"StaffButtonImage.png"];
            break;
            
        case SDProfileButtonTypePhotos:
            image = [UIImage imageNamed:@"UserProfilePhotosButton.png"];
            break;
            
        case SDProfileButtonTypeVideos:
            image = [UIImage imageNamed:@"UserProfileVideoButton.png"];
            break;
            
        case SDProfileButtonTypeBio:
            image = [UIImage imageNamed:@"UserProfileBioButton.png"];
            break;
            
        case SDProfileButtonTypeContacts:
            image = [UIImage imageNamed:@"UserProfileContactsButton.png"];
            break;
        case SDProfileButtonTypeTopSchools:
            image = [UIImage imageNamed:@"UserProfileProspectsButton.png"];
            break;
            
        default:
            break;
    }
    
    return image;
}

#pragma mark - Button methods

- (void)keyAttributesPressed
{
    [self.delegate profileButtonsViewKeyAttributesPressed:self];
}

- (void)offersPressed
{
    [self.delegate profileButtonsViewOffersPressed:self];
}

- (void)rosterPressed
{
    [self.delegate profileButtonsViewRosterPressed:self];
}

- (void)commitsPressed
{
    [self.delegate profileButtonsViewCommitsPressed:self];
}

- (void)staffPressed
{
    [self.delegate profileButtonsViewStaffPressed:self];
}

- (void)photosPressed
{
    [self.delegate profileButtonsViewPhotosPressed:self];
}

- (void)videosPressed
{
    [self.delegate profileButtonsViewVideosPressed:self];
}

- (void)bioPressed
{
    [self.delegate profileButtonsViewBioPressed:self];
}

- (void)contactsPressed
{
    [self.delegate profileButtonsViewContactsPressed:self];
}

- (void)topSchoolsPressed
{
    [self.delegate profileButtonsViewTopSchoolsPressed:self];
}

@end
