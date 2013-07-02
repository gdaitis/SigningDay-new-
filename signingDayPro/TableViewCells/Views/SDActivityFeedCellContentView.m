//
//  SDActivityFeedCellContentView.m
//  signingDayPro
//
//  Created by Lukas Kekys on 6/26/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedCellContentView.h"
#import "SDImageService.h"
#import "ActivityStory.h"
#import "SDAPIClient.h"
#import "AFNetworking.h"

@interface SDActivityFeedCellContentView ()

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.bounds.size.width-20, self.bounds.size.height-20)];
    self.contentLabel = label;
    _contentLabel.font = [UIFont systemFontOfSize:15.0f];
    _contentLabel.numberOfLines = 0;
    [self addSubview:_contentLabel];
    
    //creating imageView if cell will not have image this will be hidden
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 150)];
    self.imageView = imageView;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
}

- (void)setActivityStory:(ActivityStory *)activityStory
{
    [self recalculateSizeForActivityStory:activityStory];
}

- (void)recalculateSizeForActivityStory:(ActivityStory *)activityStory
{
    NSMutableString *contentText = [[NSMutableString alloc] init];
    if ([activityStory.activityTitle length] > 0) {
        [contentText appendFormat:@"%@\n",activityStory.activityTitle];
    }
    if ([activityStory.activityDescription length] > 0) {
        [contentText appendString:activityStory.activityDescription];
    }
    
    CGSize size = [contentText sizeWithFont:_contentLabel.font
                          constrainedToSize:CGSizeMake(_contentLabel.bounds.size.width, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = _contentLabel.frame;
    frame.size.height = size.height;
    _contentLabel.frame = frame;
    _contentLabel.text = contentText;
    
    [_imageView cancelImageRequestOperation];
    
    if ([activityStory.imagePath length] > 0) {
        
        //calculate position for photo
        frame = _imageView.frame;
        frame.origin.y = _contentLabel.frame.size.height + _contentLabel.frame.origin.y +10/*offset betwen label and photo*/;
        _imageView.frame = frame;
        
        _imageView.hidden = NO;
        NSString *fullUrl = [NSString stringWithFormat:@"%@%@",kSDAPIBaseURLString,activityStory.imagePath];
        [_imageView setImageWithURL:[NSURL URLWithString:fullUrl]];
    }
    else {
        _imageView.hidden = YES;
        _imageView.image = nil;
    }
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
