//
//  SDNotificationCell.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notification;

@interface SDNotificationCell : UITableViewCell

@property (strong, nonatomic) UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (nonatomic, strong) NSString *labelText;

@end
