//
//  SDPlayersSearchHeader.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDPlayersSearchHeader;

@protocol SDPlayersSearchHeaderDelegate <NSObject>

@optional

- (void)playersSearchHeaderPressedStatesButton:(SDPlayersSearchHeader *)playersSearchHeader;
- (void)playersSearchHeaderPressedYearsButton:(SDPlayersSearchHeader *)playersSearchHeader;
- (void)playersSearchHeaderPressedPositionsButton:(SDPlayersSearchHeader *)playersSearchHeader;
- (void)playersSearchHeaderPressedSearchButton:(SDPlayersSearchHeader *)playersSearchHeader;

@end

@interface SDPlayersSearchHeader : UIView

@property (nonatomic, weak) id <SDPlayersSearchHeaderDelegate> delegate;

@end