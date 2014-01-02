//
//  SDJoinCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJoinCellTopBottomOffset 8.0
#define kJoinCellAdditionalAttributeLabelHeight 20.0

@interface SDJoinCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *moreInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

- (void)setAdditionalAttributeArray:(NSArray *)attributeArray;
- (void)setupCellWithDictionary:(NSDictionary *)dataDictionary;
- (void)removeUnnecessaryLabels;

@end
