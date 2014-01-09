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

- (void)setupCellWithUser:(User *)user;

@end
