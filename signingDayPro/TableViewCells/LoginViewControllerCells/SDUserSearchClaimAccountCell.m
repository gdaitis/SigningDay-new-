//
//  SDUserSearchClaimAccountCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/7/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDUserSearchClaimAccountCell.h"
#import "User.h"
#import <AFNetworking.h>

@interface SDUserSearchClaimAccountCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SDUserSearchClaimAccountCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupClaimButton];
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

- (void)setupClaimButton
{
    UIImage *image = [[UIImage imageNamed:@"JoinScreenRegisterButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.claimButton setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setupCellWithUser:(User *)user
{
    [self.userImageView cancelImageRequestOperation];
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    
    self.nameLabel.text = user.name;
}

@end
