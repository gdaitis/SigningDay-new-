//
//  SDMenuLabel.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDMenuLabel.h"

@interface SDMenuLabel ()

- (void)setupLabel;

@end

@implementation SDMenuLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupLabel];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupLabel];
    }
    return self;
}

- (void)setupLabel
{
    self.font = [UIFont fontWithName:@"BebasNeue" size:20.0];
    self.textColor = [UIColor whiteColor];
    self.shadowOffset = CGSizeMake(0, 1);
    self.shadowColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
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
