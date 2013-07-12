//
//  SDActivityFeedHeaderView.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/10/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDActivityFeedHeaderView;

@protocol SDActivityFeedHeaderViewDelegate <NSObject>

@optional

- (void)activityFeedHeaderViewDidClickOnBuzzSomething:(SDActivityFeedHeaderView *)activityFeedHeaderView;
- (void)activityFeedHeaderViewDidClickOnAddMedia:(SDActivityFeedHeaderView *)activityFeedHeaderView;

@end

@interface SDActivityFeedHeaderView : UIView

@property (nonatomic, weak) IBOutlet id <SDActivityFeedHeaderViewDelegate> delegate;

@end
