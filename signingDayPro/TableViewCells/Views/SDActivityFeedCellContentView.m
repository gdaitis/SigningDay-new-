//
//  SDActivityFeedCellContentView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 6/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedCellContentView.h"

#import "ActivityStory.h"

@interface SDActivityFeedCellContentView ()

@property (nonatomic, strong) ActivityStory *activityStory;

@end

@implementation SDActivityFeedCellContentView

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
    //creating content label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-20)];
    self.contentLabel = label;
    _contentLabel.font = [UIFont systemFontOfSize:15.0f];
    [self addSubview:_contentLabel];
    
    //creating imageView if cell will not have image this will be hidden
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 150)];
    self.imageView = imageView;
    [self addSubview:_imageView];
}

- (void)setActivityStory:(ActivityStory *)activityStory
{
    _activityStory = nil;
    self.activityStory = activityStory;
    
    [self recalculateSize];
}

- (void)recalculateSize
{
//    NSMutableString *contentText = [[NSMutableString alloc] init];
//    if ([_activityStory.activityTytle length] > 0) {
//        [contentText appendFormat:@"%@\n",_activityStory.activityTytle];
//    }
//    if ([_activityStory.activityDescription length] > 0) {
//        [contentText appendString:_activityStory.activityDescription];
//    }
    NSString *contentText = @"Just a testing text now, Just a testing text now, Just a testing text now";
    
    CGSize size = [contentText sizeWithFont:_contentLabel.font
                          constrainedToSize:CGSizeMake(_contentLabel.bounds.size.width, CGFLOAT_MAX)
                              lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect frame = _contentLabel.frame;
    frame.size.height = size.height;
    _contentLabel.frame = frame;
    _contentLabel.text = contentText;
    
    //    if (_activityStory.imagePath {
    if (false) {
        _imageView.hidden = NO;
//        _imageView.image = [self getImageWithPath:imagePath];
    }
    else {
        _imageView.hidden = YES;
        _imageView.image = nil;
    }
    
    frame = _imageView.frame;
    frame.origin.y = _contentLabel.frame.size.height + _contentLabel.frame.origin.y;
    _imageView.frame = frame;
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
