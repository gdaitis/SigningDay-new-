//
//  SDNotificationCell.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDNotificationCell.h"

@interface SDNotificationCell ()

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation SDNotificationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    
    self.bottomLineView = [[UIView alloc] init];
    self.bottomLineView.backgroundColor = [UIColor colorWithRed:190.0f/255.0f
                                                          green:190.0f/255.0f
                                                           blue:190.0f/255.0f
                                                          alpha:1];
    [self addSubview:self.bottomLineView];
    
    self.cellLabel = [[UILabel alloc] init];
    self.cellLabel.numberOfLines = 0;
    self.cellLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.cellLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.cellLabel.textColor = [UIColor colorWithRed:114.0f/255.0f
                                               green:114.0f/255.0f
                                                blue:114.0f/255.0f
                                               alpha:1];
    [self addSubview:self.cellLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(256, CGFLOAT_MAX);
    CGSize expectedSize = [self.labelText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]
                                     constrainedToSize:maxSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
    CGRect newFrame = self.cellLabel.frame;
    CGPoint origin = {51, 6};
    
    newFrame.size = expectedSize;
    newFrame.origin = origin;
    self.cellLabel.frame = newFrame;
    
    self.cellLabel.text = self.labelText;
    [self.cellLabel sizeToFit];
    
    int y = expectedSize.height + 6 + 8 - 1;
    if (y < 43)
        y = 43;
    
    self.bottomLineView.frame = CGRectMake(0, y, 320, 1);
}

@end
