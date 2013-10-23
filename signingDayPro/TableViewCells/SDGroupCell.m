//
//  SDGroupCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDGroupCell.h"
#import "Group.h"

@interface SDGroupCell ()

@property (nonatomic, weak) IBOutlet UILabel *groupTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastPostLabel;
@property (nonatomic, weak) IBOutlet UILabel *postCountLabel;

@end

@implementation SDGroupCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.postCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:36.0];
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
//    [group valueForKey:@"groupTitle"];
    
    //test
    self.postCountLabel.text = @"129";
    self.groupTitleLabel.text = group.name;
    self.lastPostLabel.text = @"Last post on 29 Aug, 6:57 PM Longer longer";
    
    [self setNeedsUpdateConstraints];
}

@end
