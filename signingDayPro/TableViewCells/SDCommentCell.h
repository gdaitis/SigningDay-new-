//
//  SDCommentCell.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 7/29/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDCommentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *bottomLineView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageTextLabel;
@property (nonatomic, strong) NSString *userImageUrlString;

@end
