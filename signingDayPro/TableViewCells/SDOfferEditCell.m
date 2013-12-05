//
//  SDOfferEditCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDOfferEditCell.h"
#import "User.h"
#import "Offer.h"
#import "Team.h"
#import <AFNetworking/AFNetworking.h>

@interface SDOfferEditCell ()

@property (nonatomic, weak) IBOutlet UILabel *collegeNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *checkMarkImageView;

@end


@implementation SDOfferEditCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.checkMarkImageView.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:220.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
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

- (void)setupCellWithOffer:(Offer *)offer andPlayerCommitted:(BOOL)committed
{
    //    [group valueForKey:@"groupTitle"];
    
    //test
    self.collegeNameLabel.text = offer.team.theUser.name;
    self.checkMarkImageView.image = (committed) ? [UIImage imageNamed:@"offerCheckMark.png"] : nil;
    
    [self.avatarImageView cancelImageRequestOperation];
    self.avatarImageView.image = nil;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:offer.team.theUser.avatarUrl]];
}

@end
