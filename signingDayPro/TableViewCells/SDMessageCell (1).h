//
//  SDMessageCell.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/1/12.
//
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface SDMessageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *bottomLineView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) NSString *userImageUrlString;

@end
