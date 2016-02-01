//
//  UIImage+Resize.h
//  signingDayPro
//
//  Created by Lukas Kekys on 8/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage*)resizeImage:(UIImage*)image withWidth:(int)width withHeight:(int)height;

@end
