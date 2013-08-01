//
//  SDCommentsHeaderView.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCommentsHeaderView.h"

@implementation SDCommentsHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CommentsHeaderRightArrow.png"]];
        UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CommentsHeaderLike.png"]];
        
        self.arrowImageView.frame = CGRectMake(303, 12, self.arrowImageView.frame.size.width, self.arrowImageView.frame.size.height);
        likeImageView.frame = CGRectMake(10, 12, likeImageView.frame.size.width, likeImageView.frame.size.height);
        
        [self addSubview:self.arrowImageView];
        [self addSubview:likeImageView];
    }
    return self;
}

- (UILabel *)textLabel
{
    if (_textLabel)
        return _textLabel;
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 256, 40)];
    _textLabel.backgroundColor = [UIColor clearColor];
    
    return _textLabel;
}

- (void)setLikesCount:(NSInteger)likesCount
{
    _likesCount = likesCount;
    
    NSString *textString;
    
    if (likesCount == 1)
        textString = @"1 person likes this";
    else
        textString = [NSString stringWithFormat:@"%i people like this", likesCount];
    
    const CGFloat fontSize = 14;
    UIFont *boldFont = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
    UIFont *regularFont = [UIFont fontWithName:@"Helvetica" size:fontSize];
    UIColor *foregroundColor = [UIColor colorWithRed:103.0f/255.0f
                                               green:103.0f/255.0f
                                                blue:103.0f/255.0f
                                               alpha:1];
    NSDictionary *attributes = @{NSFontAttributeName: regularFont,
                                 NSForegroundColorAttributeName: foregroundColor};
    NSDictionary *subAttributes = @{NSFontAttributeName: boldFont,
                                    NSForegroundColorAttributeName: foregroundColor};
    
    NSRange likeRange = [textString rangeOfString:@"like"];
    NSRange boldRange = {0, likeRange.location - 1};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:textString
                                                                                       attributes:attributes];
    [attributedText setAttributes:subAttributes
                            range:boldRange];
    self.textLabel.text = textString;
    [self.textLabel setAttributedText:attributedText];
}

@end
