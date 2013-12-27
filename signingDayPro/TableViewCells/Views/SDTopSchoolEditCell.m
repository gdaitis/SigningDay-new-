//
//  SDTopSchoolEditCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/12/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDTopSchoolEditCell.h"
#import "TopSchool.h"
#import "Team.h"
#import "Player.h"
#import "User.h"
#import <AFNetworking.h>

@interface SDTopSchoolEditCell ()

@property (nonatomic, weak) IBOutlet UILabel *collegeNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIButton *interestButton;
@property (nonatomic, assign) int interestLevel;
@property (nonatomic, weak) IBOutlet UIImageView *positionNumberBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *positionLabel;

@end

@implementation SDTopSchoolEditCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.positionNumberBackgroundImageView.image = [[UIImage imageNamed:@"PlayerCellStrechableNumberImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.positionLabel.font = [UIFont fontWithName:@"BebasNeue" size:14];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
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
    self.showsReorderControl = YES;
    self.collegeNameLabel.text = topSchool.theTeam.theUser.name;
    [self setInterestLevel:[topSchool.interest intValue]];
    
    [self.avatarImageView cancelImageRequestOperation];
    self.avatarImageView.image = nil;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:topSchool.theTeam.theUser.avatarUrl]];
    
    self.positionLabel.text = [NSString stringWithFormat:@"%d",rowNumber+1];
    [self.positionLabel sizeToFit];
    CGRect frame = self.positionNumberBackgroundImageView.frame;
    frame.size.width = self.positionLabel.frame.size.width + 6;
#warning fix hardcoded values
    frame.origin.x = 124 -frame.size.width;
    self.positionNumberBackgroundImageView.frame = frame;
    self.positionLabel.frame = self.positionNumberBackgroundImageView.bounds;
}

#pragma mark - IBActions

- (IBAction)interestButtonPressed:(UIButton *)sender
{
    //    [self.delegate interestButtonSelectedInCellWithTag:self.tag];
}

@end
