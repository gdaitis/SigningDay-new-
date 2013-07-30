//
//  SDCommentCell.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/29/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCommentCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SDCommentCell

- (void)awakeFromNib
{
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    
    self.dateLabel.textColor = [UIColor colorWithRed:136.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1];
    self.messageTextLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1];
    self.bottomLineView.backgroundColor = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1];
    
    self.userImageView.layer.cornerRadius = 4.0f;
    self.userImageView.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    
    CGSize messageLabelSize = [self.messageTextLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14]
                                                     constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)
                                                         lineBreakMode:NSLineBreakByWordWrapping];
    self.messageTextLabel.frame = CGRectMake(44, 25, messageLabelSize.width + 5,  messageLabelSize.height);
    CGSize dateLabelSize = [self.dateLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14]
                                           constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)
                                               lineBreakMode:NSLineBreakByWordWrapping];
    self.dateLabel.frame = CGRectMake(self.messageTextLabel.frame.origin.x,
                                      self.messageTextLabel.frame.origin.y + self.messageTextLabel.frame.size.height + 3,
                                      dateLabelSize.width + 5,
                                      dateLabelSize.height);
    CGFloat height = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 6; // 25 + textHeight + 3 + 18 + 6
    if (height < 68) {
        height = 68;
    }
    self.bottomLineView.frame = CGRectMake(0, height - 1, 320, 1);
}

@end
