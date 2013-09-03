//
//  SDPlayersSearchHeader.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 9/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDPlayersSearchHeader.h"
#import <QuartzCore/QuartzCore.h>

@interface UIButton (AddTitle)

- (void)setCustomTitle:(NSString *)title;

@end

@implementation UIButton (AddTitle)

- (void)setCustomTitle:(NSString *)title
{
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(5, 10, 0, 0)];
    
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithRed:98.0f/255.0f
                                        green:98.0f/255.0f
                                         blue:98.0f/255.0f
                                        alpha:1.0f]
               forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
}

@end

@interface SDPlayersSearchHeader ()

@property (weak, nonatomic) IBOutlet UIButton *statesButton;
@property (weak, nonatomic) IBOutlet UIButton *yearsButton;
@property (weak, nonatomic) IBOutlet UIButton *positionsButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButtom;

@end

@implementation SDPlayersSearchHeader

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithRed:223.0f/255.0f
                                           green:223.0f/255.0f
                                            blue:223.0f/255.0f
                                           alpha:1.0f];
    
    // adding shadow
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.10f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    newShadow.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 4);
    newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
    
    [self.layer addSublayer:newShadow];
    
    // bottom line
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 189, 320, 1)];
    bottomLine.backgroundColor = [UIColor colorWithRed:168.0f/255.0f
                                                 green:168.0f/255.0f
                                                  blue:168.0f/255.0f
                                                 alpha:1.0f];
    [self addSubview:bottomLine];
    
    // titles
    [self.statesButton setCustomTitle:@"All states"];
    [self.yearsButton setCustomTitle:@"All years"];
    [self.positionsButton setCustomTitle:@"All positions"];
}

- (IBAction)statesButtonClicked:(id)sender
{
    [self.delegate playersSearchHeaderPressedStatesButton:self];
}

- (IBAction)yearsButtonClicked:(id)sender
{
    [self.delegate playersSearchHeaderPressedYearsButton:self];
}

- (IBAction)positionsButtonClicked:(id)sender
{
    [self.delegate playersSearchHeaderPressedPositionsButton:self];
}

- (IBAction)searchButtonPressed:(id)sender
{
    [self.delegate playersSearchHeaderPressedSearchButton:self];
}

@end
