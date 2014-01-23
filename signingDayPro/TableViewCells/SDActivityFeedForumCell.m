//
//  SDActivityFeedForumCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/22/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDActivityFeedForumCell.h"
#import "ActivityStory.h"
#import <DTAttributedTextContentView.h>
#import <DTLinkButton.h>
#import <DTTextBlock.h>
#import <AFNetworking.h>
#import "User.h"
#import "NSAttributedString+DTCoreText.h"
#import "SDUtils.h"

@interface SDActivityFeedForumCell () <DTAttributedTextContentViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet DTAttributedTextContentView *postTextView;

@property (weak, nonatomic) IBOutlet UIImageView *likeButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *replyButtonView;
@property (weak, nonatomic) IBOutlet UILabel *likeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;

@end

@implementation SDActivityFeedForumCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupDelegates];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupDelegates
{
    self.postTextView.delegate = self;
    self.postTextView.shouldDrawLinks = YES;
}

- (void)setupCellWithActivityStory:(ActivityStory *)activityStory atIndexPath:(NSIndexPath *)indexPath
{
    self.userNameButton.tag = indexPath.row;
    
    [self.thumbnailImageView cancelImageRequestOperation];
    self.likeButton.tag = indexPath.row;
    self.replyButton.tag = indexPath.row;
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likesCount intValue]];
    
    UIImage *buttonBackgroundImage;
    UIImage *likeImage;
    
    if ([activityStory.likedByMaster boolValue]) {
        self.likeCountLabel.textColor = [UIColor colorWithRed:183.0f/255.0f green:158.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
        self.likeTextLabel.text = @"Unlike";
        self.likeTextLabel.textColor = [UIColor colorWithRed:107.0f/255.0f green:93.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        likeImage = [UIImage imageNamed:@"LikeImageOrange"];
        buttonBackgroundImage = [[UIImage imageNamed:@"strechableBorderedImageOrange"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    } else {
        self.likeCountLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        self.likeTextLabel.text = @"Like";
        self.likeTextLabel.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        likeImage = [UIImage imageNamed:@"LikeImage"];
        buttonBackgroundImage = [[UIImage imageNamed:@"strechableBorderedImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    self.likeButtonView.image = buttonBackgroundImage;
    self.likeImageView.image = likeImage;
    
    [self.thumbnailImageView cancelImageRequestOperation];
    self.thumbnailImageView.image = nil;
    if ([activityStory.author.avatarUrl length] > 0) {
        [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:activityStory.author.avatarUrl]];
    }
    
#warning TESTING DATA, NEEDS TO BE CHANGED
    self.postTextView.backgroundColor = [UIColor greenColor];
    //    NSString *postText = @"<p>reply</p>";
    NSString *postText = @"<p><div class=\"quote-header\"></div><div class=\"quote-mycustom\"><blockquote class=\"quote\"><div class=\"quote-user\">Lukas</div><div class=\"quote-content\"><p>reply</p><p></p></div></blockquote></div><div class=\"quote-footer\"></div></p><p>Quote test</p>";
    
    NSAttributedString *attributedString = [SDUtils buildDTCoreTextStringForSigningdayWithHTMLText:postText];
    self.postTextView.attributedString = attributedString;
    
    CGSize attributedTextSize = [attributedString attributedStringSizeForWidth:kSDActivityFeedForumCellPostLabelWidth];
    CGRect frame = self.postTextView.frame;
    frame.size.height = attributedTextSize.height;
    self.postTextView.frame = frame;
    
    self.postDateLabel.text = [SDUtils formatedTimeForDate:activityStory.createdDate];
    [self setupNameLabelForActivityStory:activityStory];
}

- (void)setupNameLabelForActivityStory:(ActivityStory *)activityStory
{
    if (!activityStory)
        return;
    
    UIColor *firstColor = [UIColor colorWithRed:107.0f/255.0f green:93.0f/255.0f blue:0 alpha:1.0f];
    UIColor *secondColor = [UIColor blackColor];
    //    UIColor *thirdColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    
    User *user = activityStory.author;
    NSString *userName = [NSString stringWithFormat:@"%@",user.name];
    
    NSMutableAttributedString *authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName andColor:firstColor andFont:[UIFont boldSystemFontOfSize:12]]];
    NSMutableAttributedString *inText = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:@" in " andColor:secondColor andFont:[UIFont systemFontOfSize:12]]];
    NSMutableAttributedString *forumTitleText = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:@"General board longer text or something" andColor:secondColor andFont:[UIFont boldSystemFontOfSize:12]]];
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:authorName];
    [result appendAttributedString:inText];
    [result appendAttributedString:forumTitleText];
    
    self.nameLabel.attributedText = result;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
    CGRect newFrame = frame;
    int topPadding = 4;
    int sidePadding = 4;
    newFrame.origin.y -= topPadding;
    newFrame.size.height += topPadding*2;
    newFrame.origin.x += sidePadding;
    newFrame.size.width -= sidePadding*2;
    
	UIBezierPath *roundedFrame = [UIBezierPath bezierPathWithRoundedRect:newFrame cornerRadius:5];
    
	CGColorRef color = [textBlock.backgroundColor CGColor];
	if (color)
	{
		CGContextSetFillColorWithColor(context, color);
	}
	CGContextAddPath(context, [roundedFrame CGPath]);
	CGContextFillPath(context);
	
	CGContextAddPath(context, [roundedFrame CGPath]);
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextStrokePath(context);
	
	return NO; // draw standard background
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                          viewForLink:(NSURL *)url
                           identifier:(NSString *)identifier
                                frame:(CGRect)frame
{
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    [linkButton addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return linkButton;
}

#pragma mark - Events

- (void)linkButtonClicked:(DTLinkButton *)sender
{
    [[UIApplication sharedApplication] openURL:sender.URL];
}

@end
