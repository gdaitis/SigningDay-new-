//
//  UIView+NibLoading.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NibLoading)

+ (UIView *)loadInstanceFromNib;
+ (UIView *)loadInstanceFromClass:(id)objectClass;

@end
