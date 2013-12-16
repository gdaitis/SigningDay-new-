//
//  SDShareView.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/16/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDShareView.h"

@interface SDShareView ()

@property (nonatomic, weak) IBOutlet UIView *blackBackground;
@property (weak, nonatomic) IBOutlet UILabel *shareTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *shareTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelShareButton;

- (IBAction)shareButtonPressed:(UIButton *)sender;
- (IBAction)cancelShareButtonPressed:(UIButton *)sender;

@end

@implementation SDShareView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)shareButtonPressed:(UIButton *)sender
{
#warning change facebook and twitter enabled/disabled logic
    [self.delegate shareButtonSelectedInShareView:self withShareText:self.shareText facebookEnabled:NO twitterEnabled:NO];
}

- (IBAction)cancelShareButtonPressed:(UIButton *)sender
{
    [self.delegate dontShareButtonSelectedInShareView:self];
}
@end
