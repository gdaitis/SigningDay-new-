//
//  SDJoinCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/30/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDJoinCell.h"

#define kAdditionalLabelTag 888   //If cell is expanded additional labels are added with these tags

@interface SDJoinCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;

@end

@implementation SDJoinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAdditionalAttributeArray:(NSArray *)attributeArray
{
    int startingPointY = self.additionalInfoLabel.frame.origin.y + self.additionalInfoLabel.frame.size.height + kJoinCellTopBottomOffset;
    int xOffset = 20;
    UIFont *font = [UIFont systemFontOfSize:12.0];
    UIColor *color = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    int cellWidth = self.bounds.size.width - xOffset*2;
    
    for (NSString *attribute in attributeArray) {
        
        UILabel *label = [UILabel new];
        CGSize size = [attribute sizeWithFont:font
                              constrainedToSize:CGSizeMake(cellWidth, CGFLOAT_MAX)];
        label.text = attribute;
        label.center = self.iconImageView.center;
        CGRect frame;
        frame.origin.y = startingPointY;
        frame.origin.x = xOffset;
        frame.size.height = size.height;
        frame.size.width = cellWidth;
        label.frame = frame;
        label.tag = kAdditionalLabelTag;
        label.font = font;
        label.textColor = color;
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:label];
        
        startingPointY += size.height;
    }
}

- (void)removeUnnecessaryLabels
{
    for (UILabel *subview in self.contentView.subviews) {
        
        if (subview.tag == kAdditionalLabelTag)
            [subview removeFromSuperview];
    }
}

- (void)setupCellWithDictionary:(NSDictionary *)dataDictionary
{
    self.titleLabel.text = [dataDictionary valueForKey:@"TitleText"];
    self.iconImageView.image = [UIImage imageNamed:[dataDictionary valueForKey:@"IconImageName"]];
    self.additionalInfoLabel.text = [dataDictionary valueForKey:@"AdditionalInfoText"];
}

@end
