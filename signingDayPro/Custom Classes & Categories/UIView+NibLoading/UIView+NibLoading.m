//
//  UIView+NibLoading.m
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "UIView+NibLoading.h"

@implementation UIView (NibLoading)

- (UIView *)loadInstanceFromNib
{
    UIView *result = nil;
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner: nil options: nil];
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]){
            result = anObject;
            break;
        }
    }
    return result;
}

@end
