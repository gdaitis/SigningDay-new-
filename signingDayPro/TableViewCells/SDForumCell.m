//
//  SDDiscussionListCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDForumCell.h"
#import "Forum.h"
#import "SDUtils.h"

#define kcountLabelPositionEndX 280
#define koffsetBetweenLabels 5

@interface SDForumCell ()

@property (nonatomic, weak) IBOutlet UILabel *forumTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastPostLabel;
@property (nonatomic, weak) IBOutlet UILabel *postCountLabel;

@end

@implementation SDForumCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.postCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:36.0];
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

- (void)setupCellWithForum:(Forum *)forum
{
    self.postCountLabel.text = [NSString stringWithFormat:@"%d",[forum.threadCount intValue]];
    self.forumTitleLabel.text = forum.name;
    self.lastPostLabel.text = (forum.latestPostDate) ? [NSString stringWithFormat:@"Last post on %@",[SDUtils formatedDateStringFromDate:forum.latestPostDate]] : @"";
    
    [self updateFrames];
}

- (void)updateFrames
{
    CGSize postCountSize = [self.postCountLabel.text sizeWithFont:self.postCountLabel.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    //setup Post Count Label Frame
    CGRect frame = self.postCountLabel.frame;
    frame.size.width = postCountSize.width;
    frame.origin.x = kcountLabelPositionEndX - postCountSize.width;
    self.postCountLabel.frame = frame;
    
    //setup title label frame
    frame = self.forumTitleLabel.frame;
    frame.size.width = self.postCountLabel.frame.origin.x - koffsetBetweenLabels - frame.origin.x;
    self.forumTitleLabel.frame = frame;
    
    frame = self.lastPostLabel.frame;
    frame.size.width = self.forumTitleLabel.frame.size.width;
    self.lastPostLabel.frame = frame;
}

@end
