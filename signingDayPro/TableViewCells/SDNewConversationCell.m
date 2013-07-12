//
//  SDNewConversationCell.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/27/12.
//
//

#import "SDNewConversationCell.h"
#import "SDImageService.h"
#import "UIImage+Crop.h"
#import "AFNetworking.h"

@interface SDNewConversationCell ()

@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end

@implementation SDNewConversationCell
@synthesize bottomLine = _bottomLine;
@synthesize userImageView = _userImageView;

@synthesize userImageUrlString = _userImageUrlString;
@synthesize usernameTitle = _usernameTitle;

- (void)awakeFromNib
{
    UIView *cellBackgroundView = [[UIView alloc] init];
    [cellBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = cellBackgroundView;
    self.selectedBackgroundView.backgroundColor = kBaseSelectedCellColor;
    self.bottomLine.backgroundColor = [UIColor colorWithRed:196.0f/255.0f green:196.0f/255.0f blue:196.0f/255.0f alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
