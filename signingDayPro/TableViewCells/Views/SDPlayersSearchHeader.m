//
//  SDPlayersSearchHeader.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDPlayersSearchHeader.h"

@interface SDPlayersSearchHeader ()

@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation SDPlayersSearchHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 320,
                                kSDSearchHeaderTopMargin +
                                3*self.searchOptionButtonBgImage.size.height +
                                2*kSDSearchHeaderSpaceBetweenOptionButtons +
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
    
    self.statesButton = [self searchButtonWithBackgroundImage:self.searchOptionButtonBgImage
                                                       action:@selector(statesButtonClicked:)
                                                      yOrigin:kSDSearchHeaderTopMargin
                                                        title:@"All States"];
    [self addSubview:self.statesButton];
    
    self.yearsButton = [self searchButtonWithBackgroundImage:self.searchOptionButtonBgImage
                                                      action:@selector(yearsButtonClicked:)
                                                     yOrigin:self.statesButton.frame.origin.y + self.statesButton.frame.size.height + kSDSearchHeaderSpaceBetweenOptionButtons
                                                       title:@"All Years"];
    [self addSubview:self.yearsButton];
    
    self.positionsButton = [self searchButtonWithBackgroundImage:self.searchOptionButtonBgImage
                                                          action:@selector(positionsButtonClicked:)
                                                         yOrigin:self.yearsButton.frame.origin.y + self.yearsButton.frame.size.height + kSDSearchHeaderSpaceBetweenOptionButtons
                                                           title:@"All Positions"];
    [self addSubview:self.positionsButton];
    
    self.searchButton = [self searchButtonWithBackgroundImage:self.searchButtonBigImage
                                                       action:@selector(searchButtonPressed:)
                                                      yOrigin:self.positionsButton.frame.origin.y + self.positionsButton.frame.size.height + kSDSearchHeaderSpaceBetweenOptionButtonAndSearchButton
                                                        title:nil];
    [self addSubview:self.searchButton];
}

- (void)statesButtonClicked:(id)sender
{
    [self.delegate playersSearchHeaderPressedStatesButton:self];
}

- (void)yearsButtonClicked:(id)sender
{
    [self.delegate playersSearchHeaderPressedYearsButton:self];
}

- (void)positionsButtonClicked:(id)sender
{
    [self.delegate playersSearchHeaderPressedPositionsButton:self];
}

- (void)searchButtonPressed:(id)sender
{
    [self.delegate playersSearchHeaderPressedSearchButton:self];
}

@end
