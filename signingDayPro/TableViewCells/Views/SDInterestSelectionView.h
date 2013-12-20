//
//  SDInterestSelectionView.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDInterestSelectionView;

@protocol SDInterestSelectionViewDelegate <NSObject>

@optional

- (void)interestSelectionView:(SDInterestSelectionView *)interestView interestSelected:(int)interestLevel;

@end

@interface SDInterestSelectionView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, weak) id <SDInterestSelectionViewDelegate> delegate;

- (void)setupButtonColorsWithIndex:(int)index;

@end
