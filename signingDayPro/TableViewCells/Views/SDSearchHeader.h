//
//  SDSearchHeader.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const float kSDSearchHeaderSpaceBetweenOptionButtons;
extern const float kSDSearchHeaderSpaceBetweenOptionButtonAndSearchButton;
extern const float kSDSearchHeaderTopMargin;
extern const float kSDSearchHeaderBottomMargin;
extern const float kSDSearchHeaderLeftMargin;

@interface SDSearchHeader : UIView

@property (readonly, strong) UIImage *searchOptionButtonBgImage;
@property (readonly, strong) UIImage *searchButtonBigImage;

- (void)setupView;
- (UIButton *)searchButtonWithBackgroundImage:(UIImage *)backgroundImage
                                       action:(SEL)action
                                      yOrigin:(float)yOrigin
                                        title:(NSString *)title;

@end
