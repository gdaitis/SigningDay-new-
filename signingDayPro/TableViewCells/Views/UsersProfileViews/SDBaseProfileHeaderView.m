//
//  SDBaseProfileHeaderView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDBaseProfileHeaderView.h"



@implementation SDBaseProfileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)hideBuzzButtonView:(BOOL)hide
{
    if (hide) {
        _buzzButtonView.hidden = YES;
    }
    else {
        _buzzButtonView.hidden = NO;
    }
}

- (void)setupInfoWithUser:(User *)user
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
