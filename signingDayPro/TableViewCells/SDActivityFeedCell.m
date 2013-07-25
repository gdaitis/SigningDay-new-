//
//  SDActivityFeedCell.m
//  signingDayPro
//
//  Created by Lukas Kekys on 6/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDActivityFeedCell.h"
#import "SDActivityFeedCellContentView.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityStory.h"
#import "User.h"
#import "AFNetworking.h"
#import "SDUtils.h"

@interface SDActivityFeedCell ()

@end

@implementation SDActivityFeedCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (NSLayoutConstraint *cellConstraint in self.constraints)
    {
        [self removeConstraint:cellConstraint];
        
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        
        NSLayoutConstraint* contentViewConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                                 attribute:cellConstraint.firstAttribute
                                                                                 relatedBy:cellConstraint.relation
                                                                                    toItem:seccondItem
                                                                                 attribute:cellConstraint.secondAttribute
                                                                                multiplier:cellConstraint.multiplier
                                                                                  constant:cellConstraint.constant];
        
        [self.contentView addConstraint:contentViewConstraint];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *image = [[UIImage imageNamed:@"strechableBorderedImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *cellBackgroundImage = [[UIImage imageNamed:@"strechableCellBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 55, 10)];
    
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.image = cellBackgroundImage;
    
    self.likeButtonView.image = image;
    self.likeButtonView.backgroundColor = [UIColor clearColor];
    self.commentButtonView.image = image;
    self.commentButtonView.backgroundColor = [UIColor clearColor];
    
    self.thumbnailImageView.layer.cornerRadius = 4.0f;
    self.thumbnailImageView.clipsToBounds = YES;
    
    [self.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)setupCellWithActivityStory:(ActivityStory *)activityStory atIndexPath:(NSIndexPath *)indexPath
{
    [self.thumbnailImageView cancelImageRequestOperation];
    self.likeButton.tag = indexPath.row;
    self.commentButton.tag = indexPath.row;
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likes count]];
    self.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.comments count]];
    self.nameLabel.text =activityStory.author.name;
    [self.resizableActivityFeedView setActivityStory:activityStory];
    
    if ([activityStory.author.avatarUrl length] > 0) {
        [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:activityStory.author.avatarUrl]];
    }
    
    self.postDateLabel.text = [SDUtils formatedTimeForDate:activityStory.createdDate];
    self.yearLabel.text = @"- DE, 2014";
}

#pragma mark - like/comment button pressed

- (void)likeButtonPressed:(UIButton *)sender
{
    
}

- (void)commentButtonPressed:(UIButton *)sender
{
    
}

@end
