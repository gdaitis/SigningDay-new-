//
//  SDBuzzButtonView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/17/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDBuzzButtonView;

@protocol SDBuzzButtonViewDelegate <NSObject>

@optional

- (void)buzzSomethingButtonPressedInButtonView:(SDBuzzButtonView *)buzzButtonView;
- (void)messageButtonPressedInButtonView:(SDBuzzButtonView *)buzzButtonView;

@end

@interface SDBuzzButtonView : UIView

@property (nonatomic, weak) IBOutlet id <SDBuzzButtonViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *postButtonSmall;
@property (weak, nonatomic) IBOutlet UIButton *messageButtonSmall;
@property (weak, nonatomic) IBOutlet UIButton *postButtonBig;
@property (weak, nonatomic) IBOutlet UIButton *messageButtonBig;

@end
