//
//  SDActivityFeedCellContentView.h
//  signingDayPro
//
//  Created by Lukas Kekys on 6/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityStory;

@interface SDActivityFeedCellContentView : UIView

@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIImageView *imageView;

- (void)setActivityStory:(ActivityStory *)activityStory;

@end
