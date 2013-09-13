//
//  SDTeamsSearchHeader.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSearchHeader.h"

@class SDTeamsSearchHeader;

@protocol SDTeamsSearchHeaderDelegate <NSObject>

@optional

- (void)teamsSearchHeaderPressedConferencesButton:(SDTeamsSearchHeader *)teamsSeachHeader;
- (void)teamsSearchHeaderPressedClassButton:(SDTeamsSearchHeader *)teamsSeachHeader;
- (void)teamsSearchHeaderPressedSearchButton:(SDTeamsSearchHeader *)teamsSeachHeader;

@end

@interface SDTeamsSearchHeader : SDSearchHeader

@property (nonatomic, strong) UIButton *conferencesButton;
@property (nonatomic, strong) UIButton *classButton;
@property (nonatomic, weak) id <SDTeamsSearchHeaderDelegate> delegate;

@end
