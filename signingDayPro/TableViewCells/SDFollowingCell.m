//
//  SDFollowingCell.m
//  SigningDay
//
//  Created by Lukas Kekys on 5/13/13.
//
//

#import "SDFollowingCell.h"
#import "SDImageService.h"

@interface SDFollowingCell ()

@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end

@implementation SDFollowingCell

@synthesize bottomLine = _bottomLine;
@synthesize userImageView = _userImageView;
@synthesize userImageUrlString = _userImageUrlString;
@synthesize usernameTitle = _usernameTitle;
@synthesize followButton = _followButton;
@synthesize followingBtnSelected = _followingBtnSelected;

- (void)awakeFromNib
{
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    
    self.bottomLine.backgroundColor = [UIColor colorWithRed:196.0f/255.0f green:196.0f/255.0f blue:196.0f/255.0f alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
