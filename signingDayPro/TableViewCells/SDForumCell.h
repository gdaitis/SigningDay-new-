//
//  SDDiscussionListCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Forum;

@interface SDForumCell : UITableViewCell

- (void)setupCellWithForum:(Forum *)forum;

@end
