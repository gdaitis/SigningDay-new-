//
//  SDCantFindYourselfView.m
//  SigningDay
//
//  Created by Lukas Kekys on 1/2/14.
//  Copyright (c) 2014 Seriously inc. All rights reserved.
//

#import "SDCantFindYourselfView.h"
#import "UIView+NibLoading.h"

@interface SDCantFindYourselfView ()

@property (nonatomic, weak) IBOutlet UILabel *cantFindYourselfLabel;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

- (void)setupFonts;
- (IBAction)registerButtonPressed:(id)sender;

@end

@implementation SDCantFindYourselfView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupFonts];
}

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder
{
    if ([[self subviews] count] == 0) {
        SDCantFindYourselfView *cantFindView = (id)[SDCantFindYourselfView loadInstanceFromNib];
        cantFindView.frame = self.frame;
        cantFindView.autoresizingMask = self.autoresizingMask;
        cantFindView.alpha = self.alpha;
        
        return cantFindView;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupFonts
{
    self.cantFindYourselfLabel.font = [UIFont fontWithName:@"BebasNeue" size:23];
    self.registerButton.titleLabel.font = [UIFont fontWithName:@"BebasNeue" size:22];
}

- (IBAction)registerButtonPressed:(id)sender
{
    [self.delegate registerButtonPressedInCantFindYourselfView:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
