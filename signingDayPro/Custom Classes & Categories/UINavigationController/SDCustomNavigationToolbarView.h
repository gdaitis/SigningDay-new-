//
//  SDCustomNavigationToolbarView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDCustomNavigationToolbarView : UIView

@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;
@property (nonatomic, weak) IBOutlet UIButton *notificationButton;
@property (nonatomic, weak) IBOutlet UIButton *messagesButton;
@property (nonatomic, weak) IBOutlet UIButton *followersButton;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;


@end
