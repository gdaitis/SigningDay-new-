//
//  SDLandingPagePlayerCell.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SDLandingPagePlayerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *playerPositionLabel;
- (void)setupCellWithUser:(User *)user andFilteredData:(BOOL)dataIsFiltered;

@end
