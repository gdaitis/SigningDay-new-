//
//  SDTableView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/28/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDTableView.h"

@implementation SDTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


//makes header and footer static
- (BOOL) allowsHeaderViewsToFloat
{
    return NO;
}

- (BOOL) allowsFooterViewsToFloat
{
    return NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}


@end
