//
//  SDCustomNavigationToolbarView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCustomNavigationToolbarView.h"

@implementation SDCustomNavigationToolbarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupView
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        
        //update constraints due to ios7 different button size eval.
        NSArray *constraints = [self constraints];
        if(constraints.count != 0){
            for (NSLayoutConstraint *constraint in constraints) {
                if (constraint.constant == 6.0) {
                    constraint.constant = 10;
                }
            }
            
        }
    }
}

@end
