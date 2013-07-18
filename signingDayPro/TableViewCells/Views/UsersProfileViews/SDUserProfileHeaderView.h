//
//  SDUserProfileHeaderView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDUserProfileSlidingButtonView.h"
#import "SDBuzzButtonView.h"

@interface SDUserProfileHeaderView : UIView <SDBuzzButtonViewDelegate>

@property (nonatomic, strong) IBOutlet SDUserProfileSlidingButtonView *slidingButtonView;
@property (nonatomic, strong) IBOutlet SDBuzzButtonView *buzzButtonView;

@end
