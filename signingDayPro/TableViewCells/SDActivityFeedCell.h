//
//  SDActivityFeedCell.h
//  signingDayPro
//
//  Created by Lukas Kekys on 6/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDActivityFeedCellContentView;

@interface SDActivityFeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonsBackgroundView;
@property (weak, nonatomic) IBOutlet SDActivityFeedCellContentView *resizableActivityFeedView;


@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIImageView *likeButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *commentButtonView;
@property (weak, nonatomic) IBOutlet UILabel *likeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

- (void)setupCellWithActivityStory:(ActivityStory *)activityStory atIndexPath:(NSIndexPath *)indexPath;

@end
