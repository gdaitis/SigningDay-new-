//
//  SDMenuItemCell.h
//  signingDayPro
//
//  Created by Lukas Kekys on 5/23/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDMenuLabel;

@interface SDMenuItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet SDMenuLabel *txtLabel;

@end
