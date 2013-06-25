//
//  SDActivityFeedCell.h
//  signingDayPro
//
//  Created by Lukas Kekys on 6/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDActivityFeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UIView *resizableActivityFeedView;


@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIView *likeButtonView;
@property (weak, nonatomic) IBOutlet UIView *commentButtonView;
@property (weak, nonatomic) IBOutlet UILabel *likeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end
