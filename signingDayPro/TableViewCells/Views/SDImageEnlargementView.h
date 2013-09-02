//
//  SDImageEnlargementView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDImageEnlargementView : UIView

- (id)initWithFrame:(CGRect)frame andImage:(NSString *)imageUrl;
- (void)presentImageViewInView:(UIView *)containerView;

@end
