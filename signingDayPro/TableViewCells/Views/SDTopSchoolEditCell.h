//
//  SDTopSchoolEditCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TopSchool;

@interface SDTopSchoolEditCell : UITableViewCell

- (void)setupCellWithTopSchool:(TopSchool *)topSchool atRow:(int)rowNumber;

@end
