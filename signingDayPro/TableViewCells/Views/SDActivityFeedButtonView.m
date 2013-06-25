//
//  SDActivityFeedButtonView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 6/25/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedButtonView.h"

@implementation SDActivityFeedButtonView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupView
{
    //adding uilabel to represent text in button e.g Like/ Comment
    UILabel *textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.textLabel = textLabel;
    _textLabel.center = self.center;
    [self addSubview:_textLabel];
    
    //adding label to represent count e.g count of Likes/Comments
    UILabel *countLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.countLabel = countLabel;
    _countLabel.center = self.center;
    [self addSubview:_countLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
