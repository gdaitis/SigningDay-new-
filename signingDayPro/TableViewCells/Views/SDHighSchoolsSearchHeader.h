//
//  SDHighSchoolsSearchHeader.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSearchHeader.h"

@class SDHighSchoolsSearchHeader;

@protocol SDHighSchoolSearchHeaderDelegate <NSObject>

@optional

- (void)highSchoolSearchHeaderPressedStatesButton:(SDHighSchoolsSearchHeader *)highSchoolSearchHeader;
- (void)highSchoolSearchHeaderPressedSearchButton:(SDHighSchoolsSearchHeader *)highSchoolSearchHeader;

@end

@interface SDHighSchoolsSearchHeader : SDSearchHeader

@property (nonatomic, strong) UIButton *statesButton;
@property (nonatomic, weak) id <SDHighSchoolSearchHeaderDelegate> delegate;

@end
