//
//  SDTopSchoolsCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDTopSchoolsCell.h"
#import "TopSchool.h"
#import "Team.h"
#import "Player.h"
#import "User.h"
#import <AFNetworking.h>

@interface SDTopSchoolsCell ()

@property (nonatomic, weak) IBOutlet UILabel *collegeNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *checkMarkImageView;
@property (nonatomic, weak) IBOutlet UIButton *interestButton;
@property (nonatomic, assign) int interestLevel;
@property (nonatomic, weak) IBOutlet UIImageView *positionNumberBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;

@end

@implementation SDTopSchoolsCell


- (void)awakeFromNib
{
    [super awakeFromNib];
        self.checkMarkImageView.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:220.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
    self.positionNumberBackgroundImageView.image = [[UIImage imageNamed:@"PlayerCellStrechableNumberImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.positionLabel.font = [UIFont fontWithName:@"BebasNeue" size:14];
}

- (void)setInterestLevel:(int)interestLevel
{
    _interestLevel= interestLevel;
    
    UIImage *interestImage = nil;
    switch (interestLevel) {
        case 0:
            interestImage = [UIImage imageNamed:@"interestImage1.png"];
            break;
        case 1:
            interestImage = [UIImage imageNamed:@"interestImage1.png"];
            break;
        case 2:
            interestImage = [UIImage imageNamed:@"interestImage2.png"];
            break;
        case 3:
            interestImage = [UIImage imageNamed:@"interestImage3.png"];
            break;
        case 4:
            interestImage = [UIImage imageNamed:@"interestImage4.png"];
            break;
        case 5:
            interestImage = [UIImage imageNamed:@"interestImage5.png"];
            break;
            
        default:
            interestImage = [UIImage imageNamed:@"interestImage5.png"];
            break;
    }
    [self.interestButton setImage:interestImage forState:UIControlStateNormal];
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

- (void)setupCellWithTopSchool:(TopSchool *)topSchool atRow:(int)rowNumber
{
    self.collegeNameLabel.text = topSchool.theTeam.theUser.name;
    [self setInterestLevel:[topSchool.interest intValue]];
    self.checkMarkImageView.image = ([topSchool.hasOfferFromTeam boolValue]) ? [UIImage imageNamed:@"offerCheckMark.png"] : nil;
    
    [self.avatarImageView cancelImageRequestOperation];
    self.avatarImageView.image = nil;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:topSchool.theTeam.theUser.avatarUrl]];
    
    self.positionLabel.text = [NSString stringWithFormat:@"%d",rowNumber+1];
    [self.positionLabel sizeToFit];
    CGRect frame = self.positionNumberBackgroundImageView.frame;
    frame.size.width = self.positionLabel.frame.size.width + 6;
    frame.origin.x = self.avatarImageView.frame.origin.x + self.avatarImageView.frame.size.width -frame.size.width - 2;
    self.positionNumberBackgroundImageView.frame = frame;
    self.positionLabel.frame = self.positionNumberBackgroundImageView.bounds;
}

#pragma mark - IBActions

- (IBAction)interestButtonPressed:(UIButton *)sender
{
//    [self.delegate interestButtonSelectedInCellWithTag:self.tag];
}

@end
