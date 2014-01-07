//
//  SDCantFindYourselfView.h
//  SigningDay
//
//  Created by Lukas Kekys on 1/2/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDCantFindYourselfView;

@protocol SDCantFindYourselfViewDelegate <NSObject>

- (void)registerButtonPressedInCantFindYourselfView:(SDCantFindYourselfView *)cantFindYourselfView;

@end

@interface SDCantFindYourselfView : UIView

@property (nonatomic, assign) id <SDCantFindYourselfViewDelegate> delegate;

@end
