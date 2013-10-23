//
//  SDGroupCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDGroupCell.h"
#import "Group.h"

#define kcountLabelPositionEndX 280
#define koffsetBetweenLabels 5

@interface SDGroupCell ()

@property (nonatomic, weak) IBOutlet UILabel *groupTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastPostLabel;
@property (nonatomic, weak) IBOutlet UILabel *postCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *postLabel;

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
    self.postCountLabel.text = @"1299";
    self.groupTitleLabel.text = group.name;
    self.lastPostLabel.text = @"Last post on 29 Aug, 6:57 PM";
    
    [self updateFrames];
}

- (void)updateFrames
{
    CGSize postCountSize = [self.postCountLabel.text sizeWithFont:self.postCountLabel.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    //setup Post Count Label Frame
    CGRect frame = self.postCountLabel.frame;
    frame.size.width = postCountSize.width;
    frame.origin.x = kcountLabelPositionEndX - postCountSize.width;
    self.postCountLabel.frame = frame;
    
    //center Post Label
    frame = self.postLabel.frame;
    frame.origin.x = (self.postCountLabel.frame.origin.x + self.postCountLabel.frame.size.width/2) - frame.size.width/2;
    self.postLabel.frame = frame;
    
    //setup title label frame
    frame = self.groupTitleLabel.frame;
    frame.size.width = self.postCountLabel.frame.origin.x - koffsetBetweenLabels - frame.origin.x;
    self.groupTitleLabel.frame = frame;
    
    frame = self.lastPostLabel.frame;
    frame.size.width = self.groupTitleLabel.frame.size.width;
    self.lastPostLabel.frame = frame;
}

@end
