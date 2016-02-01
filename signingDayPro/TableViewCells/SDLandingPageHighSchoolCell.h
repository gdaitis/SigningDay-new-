//
//  SDLandingPageHighSchoolCell.h
//  signingDayPro
//
//  Created by Lukas Kekys on 9/5/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface SDLandingPageHighSchoolCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *userPositionLabel;

- (void)setupCellWithUser:(User *)user andFilteredData:(BOOL)dataIsFiltered;

@end
