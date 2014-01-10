//
//  SDUserSearchClaimAccountCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 1/7/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SDUserSearchClaimAccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *claimButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

- (void)setupCellWithUser:(User *)user;

@end
