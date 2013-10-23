//
//  SDDiscussionCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/22/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDThreadCell.h"
#import "Thread.h"

#define kcountLabelPositionEndX 310
#define koffsetBetweenLabels 5

@interface SDThreadCell ()

@property (nonatomic, weak) IBOutlet UILabel *threadTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastPostLabel;
@property (nonatomic, weak) IBOutlet UILabel *postCountLabel;

@end

@implementation SDThreadCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.postCountLabel.font = [UIFont fontWithName:@"BebasNeue" size:30.0];
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

- (void)setupCellWithThread:(Thread *)thread
{
    //    [group valueForKey:@"groupTitle"];
    
    //test
    self.postCountLabel.text = [NSString stringWithFormat:@"%d",[thread.replyCount intValue]];
    self.threadTitleLabel.text = thread.subject;
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
    
    //setup title label frame
    frame = self.threadTitleLabel.frame;
    frame.size.width = self.postCountLabel.frame.origin.x - koffsetBetweenLabels - frame.origin.x;
    self.threadTitleLabel.frame = frame;
    
    frame = self.lastPostLabel.frame;
    frame.size.width = self.threadTitleLabel.frame.size.width;
    self.lastPostLabel.frame = frame;
}

@end
