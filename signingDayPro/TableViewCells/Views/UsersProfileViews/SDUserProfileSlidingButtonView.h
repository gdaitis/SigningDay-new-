//
//  SDUserProfileSlidingButtonView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 7/15/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDUserProfileSlidingButtonView : UIView

@property (nonatomic, weak) IBOutlet UILabel *followersCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *bottomView;


//sliding menu buttons
@property (nonatomic, weak) IBOutlet UIButton *changingButton;   //this button changes depending on profile type
@property (nonatomic, weak) IBOutlet UIButton *photosButton;
@property (nonatomic, weak) IBOutlet UIButton *videosButton;
@property (nonatomic, weak) IBOutlet UIButton *bioButton;

//sliding meniu label
@property (nonatomic, weak) IBOutlet UILabel *keyAttributesLabel;



- (void)setupView;

@end
