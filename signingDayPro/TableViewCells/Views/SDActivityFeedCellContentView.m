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

@property (nonatomic, weak) UIImageView *playImageView;

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
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.contentTextView = textView;
    self.contentTextView.editable = NO;
    self.contentTextView.font = [UIFont systemFontOfSize:15.0f];
    self.contentTextView.userInteractionEnabled = NO;
    
    [self addSubview:self.contentTextView];
    
    //creating imageView if cell will not have image this will be hidden
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 152)];
    imageView.backgroundColor = [UIColor blackColor];
    self.imageView = imageView;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    
    UIImage *playImage = [UIImage imageNamed:@"playImage.png"];
    UIImageView *playButtonImageView = [[UIImageView alloc] initWithImage:playImage];
    playButtonImageView.center = _imageView.center;
    self.playImageView = playButtonImageView;
    [self.imageView addSubview:playButtonImageView];
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
    }
    else {
        if ([activityStory.activityTitle length] > 0) {
            [contentText appendFormat:@"%@\n",activityStory.activityTitle];
        }
        if ([activityStory.activityDescription length] > 0) {
            [contentText appendString:activityStory.activityDescription];
        }
    }
    
    CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:15.0f]
                          constrainedToSize:CGSizeMake(288, CGFLOAT_MAX)];
    
    CGRect frame = self.contentTextView.frame;
    frame.size.height = size.height +10;
    self.contentTextView.frame = frame;
    self.contentTextView.text = contentText;
    
    [_imageView cancelImageRequestOperation];
    _imageView.image = nil;
    
    if ([activityStory.thumbnailUrl length] > 0 || [activityStory.webPreview.imageUrl length] > 0) {
        
        //calculate position for photo
        CGRect frame = _imageView.frame;
        frame.origin.y = self.contentTextView.frame.size.height + self.contentTextView.frame.origin.y +10;
        _imageView.frame = frame;
        _imageView.hidden = NO;

        NSString *fullUrl = nil;
        if ([activityStory.thumbnailUrl length] >0) {
            
            if ([activityStory.thumbnailUrl rangeOfString:@"youtu"].location != NSNotFound) {
                //yuotube link
                fullUrl = [NSString stringWithFormat:@"http:%@",activityStory.thumbnailUrl];
                
                self.playImageView.hidden = NO;
            }
            else {
                fullUrl = [NSString stringWithFormat:@"%@%@",kSDAPIBaseURLString,activityStory.thumbnailUrl];
                self.playImageView.hidden = YES;
            }
            [_imageView setImageWithURL:[NSURL URLWithString:fullUrl]];
        }
        else {
            fullUrl = [NSString stringWithFormat:@"%@%@",kSDAPIBaseURLString,activityStory.webPreview.imageUrl];
            self.playImageView.hidden = YES;
            [_imageView setImageWithURL:[NSURL URLWithString:fullUrl]];
        }
    }
    else if ([activityStory.mediaType isEqualToString:@"videos"]) {
        //no image for video
        
        CGRect frame = _imageView.frame;
        frame.origin.y = self.contentTextView.frame.size.height + self.contentTextView.frame.origin.y +10/*offset betwen label and photo*/;
        _imageView.frame = frame;
        
        _imageView.hidden = NO;
        self.playImageView.hidden = NO;
    }
    else {
        self.playImageView.hidden = YES;
        _imageView.hidden = YES;
        _imageView.image = nil;
    }
}

@end
