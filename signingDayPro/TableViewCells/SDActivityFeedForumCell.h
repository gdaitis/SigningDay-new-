//
//  SDActivityFeedForumCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 1/22/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSDActivityFeedForumCellPostLabelWidth 243
//#define kSDActivityFeedForumCellPostLabelWidth 280

@class ActivityStory;

@interface SDActivityFeedForumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *userNameButton;

- (void)setupCellWithActivityStory:(ActivityStory *)activityStory atIndexPath:(NSIndexPath *)indexPath;

@end
