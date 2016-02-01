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

@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIImageView *imageView;

- (void)setActivityStory:(ActivityStory *)activityStory;

@end
