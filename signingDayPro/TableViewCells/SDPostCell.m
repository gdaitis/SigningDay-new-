//
//  SDPostCell.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 03/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDPostCell.h"
#import "AFNetworking.h"
#import "Thread.h"
#import "ForumReply.h"
#import "User.h"
#import "SDUtils.h"
#import "NSAttributedString+DTCoreText.h"
#import <DTAttributedTextContentView.h>
#import <DTHTMLAttributedStringBuilder.h>
#import <DTTextBlock.h>
#import <DTCSSStylesheet.h>
#import <NSAttributedString+DTCoreText.h>
#import <DTCoreTextConstants.h>
#import <DTCoreTextLayouter.h>
#import <DTAttributedTextView.h>
#import <DTLinkButton.h>

@interface SDPostCell () <DTAttributedTextContentViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sdStaffIconImageView;
@property (weak, nonatomic) IBOutlet DTAttributedTextContentView *postTextView;

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation SDPostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.believesImageView.userInteractionEnabled = YES;
    self.hatesImageView.userInteractionEnabled = YES;
    
    self.dateLabel.textColor = [UIColor colorWithRed:119.0f/255.0f
                                               green:119.0f/255.0f
                                                blue:119.0f/255.0f
                                               alpha:1.0f];
    self.believesCountLabel.textColor = [UIColor colorWithRed:101.0f/255.0f
                                                        green:178.0f/255.0f
                                                         blue:0.0f/255.0f
                                                        alpha:1.0f];
    self.hatesCountLabel.textColor = [UIColor colorWithRed:178.0f/255.0f
                                                     green:75.0f/255.0f
                                                      blue:0.0f/255.0f
                                                     alpha:1.0f];
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.bottomLineView.backgroundColor = [UIColor grayColor];
    [self addSubview:self.bottomLineView];
    
    self.postTextView.delegate = self;
    self.postTextView.shouldDrawLinks = YES;
    
    self.userAvatarImageView.layer.cornerRadius = 4.0f;
    self.userAvatarImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithDataObject:(id)dataObject
{
    NSString *avatarUrl;// = @"http://dev.signingday.com/resized-image.ashx/__size/245x230/__key/communityserver-components-avatars/00-00-03-87-07/4TOGZ3UKM8DW.png";
    NSString *userName;// = @"Sam Poggi sdfg sdfg";
    BOOL isSDStaff;
    NSString *postText;// = @"Aasdjfg kadshfgsherjgsdnfbvn ansdf asldfj a;lksdfl jvbn xcn va;lsdhtj sdfnv xclvjkbs;fjg sd;fn sdn fljalsdjf sdf";
    NSString *dateText;// = @"on 5 Feb 2013 11:24 PM";
    int believesCount;// = 45;
    int hatesCount;// = 30;
    
    if ([dataObject isKindOfClass:[Thread class]]) {
        Thread *thread = (Thread *)dataObject;
        avatarUrl = thread.authorUser.avatarUrl;
        userName = thread.authorUser.name;
        postText = thread.bodyText;
        dateText = [SDUtils formatedTimeForDate:thread.date];
        believesCount = [thread.countOfBelieves integerValue];
        hatesCount = [thread.countOfHates integerValue];
        isSDStaff = [thread.authorUser.isSDStaff boolValue];
    } else if ([dataObject isKindOfClass:[ForumReply class]]) {
        ForumReply *forumReply = (ForumReply *)dataObject;
        avatarUrl = forumReply.authorUser.avatarUrl;
        userName = forumReply.authorUser.name;
        postText = forumReply.bodyText;
        dateText = [SDUtils formatedTimeForDate:forumReply.date];
        believesCount = [forumReply.countOfBelieves integerValue];
        hatesCount = [forumReply.countOfHates integerValue];
        isSDStaff = [forumReply.authorUser.isSDStaff boolValue];
    } else {
        return;
    }
    NSString *believesCountString = [NSString stringWithFormat:@"%d", believesCount];
    NSString *hatesCountString = [NSString stringWithFormat:@"%d", hatesCount];
    
    // Avatar
    [self.userAvatarImageView setImageWithURL:[NSURL URLWithString:avatarUrl]];
    
    // Name label
    CGSize nameLabelSize = [userName sizeWithFont:[UIFont boldSystemFontOfSize:kSDPostCellDefaultFontSize]
                                constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    CGRect nameLabelFrame = self.userNameLabel.frame;
    
    nameLabelFrame.size.width = (nameLabelSize.width < kSDPostCellMaxNameLabelWidth) ? ceilf(nameLabelSize.width) : kSDPostCellMaxNameLabelWidth;
    self.userNameLabel.frame = nameLabelFrame;
    self.userNameLabel.text = userName;
    
    // SD Staff logo
    if (isSDStaff) {
        self.sdStaffIconImageView.hidden = NO;
        CGRect sdStaffLogoFrame = self.sdStaffIconImageView.frame;
        sdStaffLogoFrame.origin.x = self.userNameLabel.frame.origin.x + self.userNameLabel.frame.size.width + kSDPostCellNameLabelAndSDStaffLogoGapWidth;
        self.sdStaffIconImageView.frame = sdStaffLogoFrame;
    } else {
        self.sdStaffIconImageView.hidden = YES;
    }
    
    NSAttributedString *attributedString = [SDUtils buildDTCoreTextStringForSigningdayWithHTMLText:postText];
    self.postTextView.attributedString = attributedString;
    
    CGSize attributedTextSize = [attributedString attributedStringSizeForWidth:kSDPostCellMaxPostLabelWidth];
    CGRect frame = self.postTextView.frame;
    frame.size.height = attributedTextSize.height;
    self.postTextView.frame = frame;
    
    
    // Date text label
    CGSize dateLabelSize = [dateText sizeWithFont:[UIFont systemFontOfSize:kSDPostCellDefaultFontSize]
                                constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    CGRect dateLabelFrame = self.dateLabel.frame;
    dateLabelFrame.origin.y = self.postTextView.frame.origin.y + self.postTextView.frame.size.height + kSDPostCellPostTextAndDateLabelGapHeight;
    dateLabelFrame.size.width = (dateLabelSize.width < kSDPostCellMaxDateLabelWidth) ? ceilf(dateLabelSize.width) : kSDPostCellMaxDateLabelWidth;
    self.dateLabel.frame = dateLabelFrame;
    self.dateLabel.text = dateText;
    
    // Believes / hates
    CGRect believesIconFrame = self.believesImageView.frame;
    believesIconFrame.origin.y = self.dateLabel.frame.origin.y;
    self.believesImageView.frame = believesIconFrame;
    
    CGRect hatesIconFrame = self.hatesImageView.frame;
    hatesIconFrame.origin.y = self.dateLabel.frame.origin.y;
    self.hatesImageView.frame = hatesIconFrame;
    
    CGSize believesCountLabelSize = [believesCountString sizeWithFont:[UIFont systemFontOfSize:kSDPostCellDefaultFontSize]
                                                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                        lineBreakMode:NSLineBreakByWordWrapping];
    CGRect believesCountLabelFrame = self.believesCountLabel.frame;
    believesCountLabelFrame.size = believesCountLabelSize;
    believesCountLabelFrame.origin.y = self.believesImageView.frame.origin.y;
    believesCountLabelFrame.origin.x = self.believesImageView.frame.origin.x - kSDPostCellWidthOfGapBetweenHatesOrLikesCountAndIncon - believesCountLabelFrame.size.width;
    self.believesCountLabel.frame = believesCountLabelFrame;
    self.believesCountLabel.text = believesCountString;
    
    CGSize hatesCountLabelSize = [hatesCountString sizeWithFont:[UIFont systemFontOfSize:kSDPostCellDefaultFontSize]
                                              constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                  lineBreakMode:NSLineBreakByWordWrapping];
    CGRect hatesCountLabelFrame = self.hatesCountLabel.frame;
    hatesCountLabelFrame.size = hatesCountLabelSize;
    hatesCountLabelFrame.origin.y = self.hatesImageView.frame.origin.y;
    hatesCountLabelFrame.origin.x = self.hatesImageView.frame.origin.x + self.hatesImageView.frame.size.width + kSDPostCellWidthOfGapBetweenHatesOrLikesCountAndIncon;
    self.hatesCountLabel.frame = hatesCountLabelFrame;
    self.hatesCountLabel.text = hatesCountString;
    
    // Bottom line
    self.bottomLineView.frame = CGRectMake(0,
                                           self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + kSDPostCellDateLabelAndBottomLineGapHeight,
                                           320,
                                           1);
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
    CGRect newFrame = frame;
    int padding = 4;
    newFrame.origin.y -= padding;
    newFrame.size.height += padding*2;
    
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