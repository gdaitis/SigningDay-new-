//
//  SDTeamsSearchHeader.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDTeamsSearchHeader.h"

@interface SDTeamsSearchHeader ()

@property (nonatomic, strong) UIButton *conferencesButton;
@property (nonatomic, strong) UIButton *classButton;
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation SDTeamsSearchHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 320,
                                kSDSearchHeaderTopMargin +
                                2*self.searchOptionButtonBgImage.size.height +
                                kSDSearchHeaderSpaceBetweenOptionButtons +
                                kSDSearchHeaderSpaceBetweenOptionButtonAndSearchButton +
                                self.searchButtonBigImage.size.height +
                                kSDSearchHeaderBottomMargin);
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [super setupView];
    
    self.conferencesButton = [self searchButtonWithBackgroundImage:self.searchOptionButtonBgImage
                                                            action:@selector(conferencesButtonClicked:)
                                                           yOrigin:kSDSearchHeaderTopMargin
                                                             title:@"All Conferences"];
    [self addSubview:self.conferencesButton];
    
    self.classButton = [self searchButtonWithBackgroundImage:self.searchOptionButtonBgImage
                                                      action:@selector(classButtonClicked:)
                                                     yOrigin:self.conferencesButton.frame.origin.y + self.conferencesButton.frame.size.height + kSDSearchHeaderSpaceBetweenOptionButtons
                                                       title:@"Class"];
    [self addSubview:self.classButton];
    
    self.searchButton = [self searchButtonWithBackgroundImage:self.searchButtonBigImage
                                                       action:@selector(searchButtonClicked:)
                                                      yOrigin:self.classButton.frame.origin.y + self.classButton.frame.size.height + kSDSearchHeaderSpaceBetweenOptionButtonAndSearchButton
                                                        title:nil];
    [self addSubview:self.searchButton];
}

- (void)conferencesButtonClicked:(id)sender
{
    [self.delegate teamsSearchHeaderPressedConferencesButton:self];
}

- (void)classButtonClicked:(id)sender
{
    [self.delegate teamsSearchHeaderPressedClassButton:self];
}

- (void)searchButtonClicked:(id)sender
{
    [self.delegate teamsSearchHeaderPressedSearchButton:self];
}

@end
