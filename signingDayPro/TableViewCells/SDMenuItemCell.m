//
//  SDMenuItemCell.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/23/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDMenuItemCell.h"
#import "SDMenuLabel.h"

@implementation SDMenuItemCell

@synthesize imgView = _imgView;
@synthesize txtLabel = _txtLabel;

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

@end
