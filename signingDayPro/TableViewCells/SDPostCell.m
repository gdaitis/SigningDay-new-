//
//  SDPostCell.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 03/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDPostCell.h"
#import "AFNetworking.h"

@interface SDPostCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sdStaffIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *believesImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hatesImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *believesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hatesCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

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
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.bottomLineView.backgroundColor = [UIColor grayColor];
    [self addSubview:self.bottomLineView];
    
    [self setupWithSmthn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithSmthn
{
    NSString *avatarUrl = @"http://dev.signingday.com/resized-image.ashx/__size/245x230/__key/communityserver-components-avatars/00-00-03-87-07/4TOGZ3UKM8DW.png";
    NSString *userName = @"Sam Poggi sdfg sdfg";
    BOOL isSDStaff = YES;
    NSString *postText = @"Aasdjfg kadshfgsherjgsdnfbvn ansdf asldfj a;lksdfl jvbn xcn va;lsdhtj sdfnv xclvjkbs;fjg sd;fn sdn fljalsdjf sdf";
    NSString *dateText = @"on 5 Feb 2013 11:24 PM";
    int believesCount = 45;
    NSString *believesCountString = [NSString stringWithFormat:@"%d", believesCount];
    int hatesCount = 30;
    NSString *hatesCountString = [NSString stringWithFormat:@"%d", hatesCount];
    
    // Avatar
    [self.userAvatarImageView setImageWithURL:[NSURL URLWithString:avatarUrl]];
    
    // Name label
    CGSize nameLabelSize = [userName sizeWithFont:[UIFont boldSystemFontOfSize:kSDPostCellDefaultFontSize]
                                constrainedToSize:CGSizeMake(kSDPostCellMaxNameLabelWidth, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect nameLabelFrame = self.userNameLabel.frame;
    nameLabelFrame.size.width = nameLabelSize.width;
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
    
    // Post text
    CGSize postTextSize = [postText sizeWithFont:[UIFont systemFontOfSize:kSDPostCellDefaultFontSize]
                               constrainedToSize:CGSizeMake(kSDPostCellMaxPostLabelWidth, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    CGRect postTextViewFrame = self.postTextView.frame;
    postTextViewFrame.size = postTextSize;
    self.postTextView.frame = postTextViewFrame;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.postTextView.contentInset = UIEdgeInsetsMake(-4,-4,0,0);
    else
        self.postTextView.contentInset = UIEdgeInsetsMake(-8,-8,0,0);
    self.postTextView.text = postText;
    
    // Date text label
    CGSize dateLabelSize = [dateText sizeWithFont:[UIFont systemFontOfSize:kSDPostCellDefaultFontSize]
                                constrainedToSize:CGSizeMake(kSDPostCellMaxDateLabelWidth, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect dateLabelFrame = self.dateLabel.frame;
    dateLabelFrame.origin.y = self.postTextView.frame.origin.y + self.postTextView.frame.size.height + kSDPostCellPostTextAndDateLabelGapHeight;
    dateLabelFrame.size.width = dateLabelSize.width;
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

@end









