//
//  SDMessageCell.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/1/12.
//
//

#import "SDMessageCell.h"
#import "User.h"
#import "AFNetworking.h"
#import "SDImageService.h"
#import "UIImage+Crop.h"
#import "DTCoreText.h"
#import "SDBaseChatViewController.h"

@interface SDMessageCell ()

@end

@implementation SDMessageCell

- (void)awakeFromNib
{
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    
    self.dateLabel.textColor = [UIColor colorWithRed:136.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1];
    self.messageTextView.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1];
    self.bottomLineView.backgroundColor = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.messageTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    
    CGRect rect = [self.messageTextView.attributedText boundingRectWithSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                    context:nil];
    self.messageTextView.frame = CGRectMake(64, 31, kMessageTextWidth, rect.size.height);
    CGFloat height = rect.size.height + 31 + 12 - 16;
    
    if (height < 67) {
        height = 67;
    }
    self.bottomLineView.frame = CGRectMake(0, height, 320, 1);
}

@end
