//
//  SDInterestSelectionView.m
//  SigningDay
//
//  Created by Lukas Kekys on 12/19/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDInterestSelectionView.h"


#define kFirstColor [UIColor colorWithRed:28.0f/255.0f green:138.0f/255.0f blue:4.0f/255.0f alpha:1.0f]
#define kSecondColor [UIColor colorWithRed:133.0f/255.0f green:142.0f/255.0f blue:5.0f/255.0f alpha:1.0f]
#define kThirdColor [UIColor colorWithRed:235.0f/255.0f green:115.0f/255.0f blue:9.0f/255.0f alpha:1.0f]
#define kFourthColor [UIColor colorWithRed:243.0f/255.0f green:38.0f/255.0f blue:30.0f/255.0f alpha:1.0f]
#define kFifthColor [UIColor colorWithRed:188.0f/255.0f green:0.0f/255.0f blue:8.0f/255.0f alpha:1.0f]
#define kUnselectedColor [UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f]

@interface SDInterestSelectionView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthButton;
@property (weak, nonatomic) IBOutlet UIButton *fifthButton;

- (IBAction)buttonPressed:(UIButton *)sender;

@end

@implementation SDInterestSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupButtonColorsWithIndex:(int)index
{
    [self clearAllButtonColors];
    
    if (index == 1) {
        self.firstButton.backgroundColor = kFirstColor;
    }
    else if (index == 2) {
        self.firstButton.backgroundColor = kFirstColor;
        self.secondButton.backgroundColor = kSecondColor;
    }
    else if (index == 3) {
        self.firstButton.backgroundColor = kFirstColor;
        self.secondButton.backgroundColor = kSecondColor;
        self.thirdButton.backgroundColor = kThirdColor;
    }
    else if (index == 4) {
        self.firstButton.backgroundColor = kFirstColor;
        self.secondButton.backgroundColor = kSecondColor;
        self.thirdButton.backgroundColor = kThirdColor;
        self.fourthButton.backgroundColor = kFourthColor;
    }
    else if (index == 5) {
        self.firstButton.backgroundColor = kFirstColor;
        self.secondButton.backgroundColor = kSecondColor;
        self.thirdButton.backgroundColor = kThirdColor;
        self.fourthButton.backgroundColor = kFourthColor;
        self.fifthButton.backgroundColor = kFifthColor;
    }
    else {
        self.firstButton.backgroundColor = kFirstColor;
    }
    
}

- (void)clearAllButtonColors
{
    self.firstButton.backgroundColor =
    self.secondButton.backgroundColor =
    self.thirdButton.backgroundColor =
    self.fourthButton.backgroundColor =
    self.fifthButton.backgroundColor = kUnselectedColor;
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    [self setupButtonColorsWithIndex:sender.tag];
    NSLog(@"button tag = %d",sender.tag);
    [self.delegate interestSelectionView:self interestSelected:sender.tag];
}

@end
