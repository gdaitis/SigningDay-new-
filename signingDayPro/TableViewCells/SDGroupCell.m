//
//  SDGroupCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDGroupCell.h"
#import "Group.h"
#import "SDUtils.h"

#define kcountLabelPositionEndX 280
#define koffsetBetweenLabels 5

@interface SDGroupCell ()

@property (nonatomic, weak) IBOutlet UILabel *groupTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastPostLabel;

@end

@implementation SDGroupCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

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

- (void)setupCellWithGroup:(Group *)group
{
    self.groupTitleLabel.text = group.name;
    self.lastPostLabel.text = [SDUtils formatedDateStringFromDate:group.dateCreated];
}

@end
