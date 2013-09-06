//
//  SDHighSchoolsSearchHeader.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDHighSchoolsSearchHeader.h"

@interface SDHighSchoolsSearchHeader ()

@property (nonatomic, strong) UIButton *statesButton;
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation SDHighSchoolsSearchHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 320,
                                kSDSearchHeaderTopMargin +
                                self.searchOptionButtonBgImage.size.height +
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
    
    self.searchButton = [self searchButtonWithBackgroundImage:self.searchButtonBigImage
                                                       action:@selector(searchButtonClicked:)
                                                      yOrigin:self.statesButton.frame.origin.y + self.statesButton.frame.size.height + kSDSearchHeaderSpaceBetweenOptionButtonAndSearchButton
                                                        title:nil];
    [self addSubview:self.searchButton];
}

- (void)statesButtonClicked:(id)sender
{
    [self.delegate highSchoolSearchHeaderPressedStatesButton:self];
}

- (void)searchButtonClicked:(id)sender
{
    [self.delegate highSchoolSearchHeaderPressedSearchButton:self];
}

@end
