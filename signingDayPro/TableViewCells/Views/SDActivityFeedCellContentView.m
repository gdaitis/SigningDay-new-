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
#import "WebPreview.h"

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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 152)];
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
    
    if (activityStory.webPreview) {
        
        if ([activityStory.webPreview.link length] > 0) {
            [contentText appendFormat:@"%@\n\n",activityStory.webPreview.link];
        }
        if ([activityStory.webPreview.siteName length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.siteName];
        }
        if ([activityStory.webPreview.webPreviewTitle length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.webPreviewTitle];
        }
        if ([activityStory.webPreview.excerpt length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.webPreview.excerpt];
        }
    }
    else {
        if ([activityStory.activityTitle length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.activityTitle];
        }
        if ([activityStory.activityDescription length] > 0) {
            [contentText appendString:activityStory.activityDescription];
        }
    }
    
    CGSize size = [contentText sizeWithFont:_contentLabel.font
                          constrainedToSize:CGSizeMake(_contentLabel.bounds.size.width, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = _contentLabel.frame;
    frame.size.height = size.height;
    _contentLabel.frame = frame;
    _contentLabel.text = contentText;
    
    [_imageView cancelImageRequestOperation];
    
    if ([activityStory.thumbnailUrl length] > 0 || [activityStory.webPreview.imageUrl length] > 0) {
        
        //calculate position for photo
        frame = _imageView.frame;
        frame.origin.y = _contentLabel.frame.size.height + _contentLabel.frame.origin.y +10/*offset betwen label and photo*/;
        _imageView.frame = frame;
        
        _imageView.hidden = NO;
        
#warning not optimized must not set background color and user normal images
        _imageView.image = nil;
        _imageView.backgroundColor = [UIColor clearColor];
        UIView *playView = [_imageView viewWithTag:888];
        if (playView) {
            [playView removeFromSuperview];
        }
        
        
        
        NSString *fullUrl = nil;
        if ([activityStory.thumbnailUrl length] >0) {
            
            
            if ([activityStory.thumbnailUrl rangeOfString:@"youtube"].location != NSNotFound) {
                //yuotube link
                fullUrl = [NSString stringWithFormat:@"http:%@",activityStory.thumbnailUrl];
                
#warning needs optimizations
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.imageView.bounds];
                imageView.image = [UIImage imageNamed:@"playImage.png"];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.tag = 888;
                [self.imageView addSubview:imageView];
                NSLog(@"YOUTUBE url = %@",fullUrl);
            }
            else {
                fullUrl = [NSString stringWithFormat:@"%@%@",kSDAPIBaseURLString,activityStory.thumbnailUrl];
            }
            [_imageView setImageWithURL:[NSURL URLWithString:fullUrl]];
        }
        else {
            fullUrl = [NSString stringWithFormat:@"%@%@",kSDAPIBaseURLString,activityStory.webPreview.imageUrl];
            [_imageView setImageWithURL:[NSURL URLWithString:fullUrl]];
        }
    }
    else if ([activityStory.mediaType isEqualToString:@"videos"]) {
        //no image for video
        
        frame = _imageView.frame;
        frame.origin.y = _contentLabel.frame.size.height + _contentLabel.frame.origin.y +10/*offset betwen label and photo*/;
        _imageView.frame = frame;
        
        _imageView.hidden = NO;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.image = [UIImage imageNamed:@"playImage@2x.png"];
    }
    else {
        _imageView.hidden = YES;
        _imageView.image = nil;
    }
}

@end
