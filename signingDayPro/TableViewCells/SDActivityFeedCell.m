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
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.likesCount intValue]];
    self.commentCountLabel.text = [NSString stringWithFormat:@"- %d",[activityStory.commentCount intValue]];
    [self.resizableActivityFeedView setActivityStory:activityStory];
    
    if ([activityStory.author.avatarUrl length] > 0) {
        [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:activityStory.author.avatarUrl]];
    }
    
    self.postDateLabel.text = [SDUtils formatedTimeForDate:activityStory.createdDate];
    [self setupNameLabelForActivityStory:activityStory];
}

- (void)setupNameLabelForActivityStory:(ActivityStory *)activityStory
{
    //this function setups attributed user name. If user has parameters adds them, also if activityStory is a wallpost adds arrows and appends other user name
    
    if (!activityStory)
        return;
    
    NSMutableAttributedString *authorName = nil;
    if (activityStory.postedToUser) {
        //this is a wall post
        
        
        //form first user name and attributes
        User *user = activityStory.author;
        NSString *userName = [NSString stringWithFormat:@"%@ ",user.name];
        NSString *attributes = [SDUtils attributeStringForUser:user];
        UIColor *firstColor = [UIColor colorWithRed:107.0f/255.0f green:93.0f/255.0f blue:0 alpha:1.0f];
        UIColor *secondColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        if (attributes) {
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName firstColor:firstColor andSecondText:attributes andSecondColor:secondColor andFirstFont:[UIFont boldSystemFontOfSize:12] andSecondFont:[UIFont systemFontOfSize:12]]];
        }
        else {
            //nsattributed string just for name
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName andColor:firstColor andFont:[UIFont boldSystemFontOfSize:12]]];
        }
        
        //append arrow
        NSAttributedString *arrowString = [[NSAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:@" \u25B8 " andColor:secondColor andFont:[UIFont systemFontOfSize:12]]];
        [authorName appendAttributedString:arrowString];
        
        
        //form second user name
        NSMutableAttributedString *secondUserName = nil;
        User *secondUser = activityStory.postedToUser;
        NSString *secondUserAttributes = [SDUtils attributeStringForUser:secondUser];
        if (secondUserAttributes) {
            secondUserName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:secondUser.name firstColor:firstColor andSecondText:secondUserAttributes andSecondColor:secondColor andFirstFont:[UIFont boldSystemFontOfSize:12] andSecondFont:[UIFont systemFontOfSize:12]]];
        }
        else {
            //nsattributed string just for name
            secondUserName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:secondUser.name andColor:firstColor andFont:[UIFont boldSystemFontOfSize:12]]];
        }
        
        //apend name to the result
        [authorName appendAttributedString:secondUserName];
        
    }
    else {
        //simple post
        User *user = activityStory.author;
        NSString *userName = [NSString stringWithFormat:@"%@ ",user.name];
        
        NSString *attributes = [SDUtils attributeStringForUser:user];
        UIColor *firstColor = [UIColor colorWithRed:107.0f/255.0f green:93.0f/255.0f blue:0 alpha:1.0f];
        UIColor *secondColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
        if (attributes) {
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName firstColor:firstColor andSecondText:attributes andSecondColor:secondColor andFirstFont:[UIFont boldSystemFontOfSize:12] andSecondFont:[UIFont systemFontOfSize:12]]];
        }
        else {
            //nsattributed string just for name
            authorName = [[NSMutableAttributedString alloc] initWithAttributedString:[SDUtils attributedStringWithText:userName andColor:firstColor andFont:[UIFont boldSystemFontOfSize:12]]];
        }
    }
    self.nameLabel.attributedText = authorName;
}

@end
