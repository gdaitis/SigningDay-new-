//
//  SDLandingPageCollegeCell.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/5/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SDLandingPageCollegeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *playerPositionLabel;

- (void)setupCellWithUser:(User *)user andFilteredData:(BOOL)dataIsFiltered;

@end
