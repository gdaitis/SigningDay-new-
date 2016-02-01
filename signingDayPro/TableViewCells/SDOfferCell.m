//
//  SDOfferCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 10/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDOfferCell.h"
#import "User.h"
#import "Offer.h"
#import "Team.h"
#import <AFNetworking/AFNetworking.h>

@interface SDOfferCell ()

@property (nonatomic, weak) IBOutlet UILabel *collegeNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *checkMarkImageView;

@end

@implementation SDOfferCell

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

- (void)setupCellWithOffer:(Offer *)offer
{
    //    [group valueForKey:@"groupTitle"];
    
    //test
    self.collegeNameLabel.text = offer.team.theUser.name;
    
    self.checkMarkImageView.hidden = ([offer.playerCommited boolValue]) ? NO : YES;
    
    [self.avatarImageView cancelImageRequestOperation];
    self.avatarImageView.image = nil;
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:offer.team.theUser.avatarUrl]];
}

@end
