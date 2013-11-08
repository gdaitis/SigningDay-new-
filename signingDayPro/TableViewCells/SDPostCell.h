//
//  SDPostCell.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 03/11/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSDPostCellDefaultFontSize 13
#define kSDPostCellMaxNameLabelWidth 217
#define kSDPostCellNameLabelAndSDStaffLogoGapWidth 7
#define kSDPostCellMaxPostLabelWidth 243
#define kSDPostCellPostTextAndDateLabelGapHeight 14
#define kSDPostCellMaxDateLabelWidth 175
#define kSDPostCellWidthOfGapBetweenHatesOrLikesCountAndIncon 5
#define kSDPostCellDateLabelAndBottomLineGapHeight 13

@interface SDPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *believesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hatesCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *believesImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hatesImageView;

- (void)setupWithDataObject:(id)dataObject;

@end
