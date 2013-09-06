//
//  SDSearchHeader.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

float const kSDSearchHeaderSpaceBetweenOptionButtons = 9;
float const kSDSearchHeaderSpaceBetweenOptionButtonAndSearchButton = 10;
float const kSDSearchHeaderTopMargin = 8;
float const kSDSearchHeaderBottomMargin = 15;
float const kSDSearchHeaderLeftMargin = 11;

@interface SDSearchHeader : UIView

@property (readonly, strong) UIImage *searchOptionButtonBgImage;
@property (readonly, strong) UIImage *searchButtonBigImage;

- (void)setupView;
- (UIButton *)searchButtonWithBackgroundImage:(UIImage *)backgroundImage
                                       action:(SEL)action
                                      yOrigin:(float)yOrigin
                                        title:(NSString *)title;

@end
