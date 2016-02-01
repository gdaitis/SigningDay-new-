//
//  SDPlayersSearchHeader.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSearchHeader.h"

@class SDPlayersSearchHeader;

@protocol SDPlayersSearchHeaderDelegate <NSObject>

@optional

- (void)playersSearchHeaderPressedStatesButton:(SDPlayersSearchHeader *)playersSearchHeader;
- (void)playersSearchHeaderPressedYearsButton:(SDPlayersSearchHeader *)playersSearchHeader;
- (void)playersSearchHeaderPressedPositionsButton:(SDPlayersSearchHeader *)playersSearchHeader;
- (void)playersSearchHeaderPressedSearchButton:(SDPlayersSearchHeader *)playersSearchHeader;

@end

@interface SDPlayersSearchHeader : SDSearchHeader

@property (nonatomic, strong) UIButton *statesButton;
@property (nonatomic, strong) UIButton *yearsButton;
@property (nonatomic, strong) UIButton *positionsButton;
@property (nonatomic, weak) id <SDPlayersSearchHeaderDelegate> delegate;

@end