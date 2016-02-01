//
//  SDContentHeaderView.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/6/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDContentHeaderView : UIView
{
    UILabel *_textLabel;
}

- (UILabel *)textLabel;
- (void)setTextLabel:(UILabel *)textLabel;

@end
