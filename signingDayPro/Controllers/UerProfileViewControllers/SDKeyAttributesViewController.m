//
//  SDKeyAttributesViewController.m
//  signingDayPro
//
//  Created by Lukas Kekys on 9/4/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDKeyAttributesViewController.h"
#import "User.h"
#import "SDProfileService.h"


@interface SDKeyAttributesViewController ()

//labels are different depending on user types, so using default naming
@property (nonatomic, weak) IBOutlet UILabel *firstLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondLabel;
@property (nonatomic, weak) IBOutlet UILabel *thirdLabel;
@property (nonatomic, weak) IBOutlet UILabel *fourthLabel;
@property (nonatomic, weak) IBOutlet UILabel *fifthLabel;

@property (nonatomic, weak) IBOutlet UIImageView *firstImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondImageView;
@property (nonatomic, weak) IBOutlet UIImageView *thirdImageView;
@property (nonatomic, weak) IBOutlet UIImageView *fourthImageView;
@property (nonatomic, weak) IBOutlet UIImageView *fifthImageView;

@property (nonatomic, assign) float firstValue;
@property (nonatomic, assign) float secondValue;
@property (nonatomic, assign) float thirdValue;
@property (nonatomic, assign) float fourthValue;
@property (nonatomic, assign) float fifthValue;


@end

@implementation SDKeyAttributesViewController

#pragma mark - Setters

- (void)setFirstValue:(float)firstValue
{
    _firstValue  = [self roundedFloatFromValue:firstValue];
    [self setupAttributeView:self.firstImageView withFloatValue:_firstValue];
}

- (void)setSecondValue:(float)secondValue
{
    _secondValue  = [self roundedFloatFromValue:secondValue];
    [self setupAttributeView:self.secondImageView withFloatValue:_secondValue];
}

- (void)setThirdValue:(float)thirdValue
{
    _thirdValue  = [self roundedFloatFromValue:thirdValue];
    [self setupAttributeView:self.thirdImageView withFloatValue:_thirdValue];
}

- (void)setFourthValue:(float)fourthValue
{
    _fourthValue = [self roundedFloatFromValue:fourthValue];
    [self setupAttributeView:self.fourthImageView withFloatValue:_fourthValue];
}

- (void)setFifthValue:(float)fifthValue
{
    _fifthValue  = [self roundedFloatFromValue:fifthValue];
    [self setupAttributeView:self.fifthImageView withFloatValue:_fifthValue];
}


#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadData
{
    [self showProgressHudInView:self.view withText:@"Loading"];
    [SDProfileService getKeyAttributesForUserWithIdentifier:self.userIdentifierString completionBlock:^(NSArray *results) {
        [self updateValuesFromArray:results];
        [self hideProgressHudInView:self.view];
    } failureBlock:^{
        NSLog(@"FAILURE in keyattributes controller");
        [self hideProgressHudInView:self.view];
    }];
}

- (void)updateValuesFromArray:(NSArray *)infoArray
{
    for (int i = 0; i<[infoArray count]; i++) {
        NSDictionary *infoDictionary = [infoArray objectAtIndex:i];
        if (i == 0) {
            [self setFirstValue:[[infoDictionary valueForKey:@"Value"] floatValue]];
            self.firstLabel.text = [infoDictionary valueForKey:@"Name"];
            self.firstLabel.hidden = NO;
            self.firstImageView.hidden = NO;
        }
        else if (i ==1) {
            [self setSecondValue:[[infoDictionary valueForKey:@"Value"] floatValue]];
            self.secondLabel.text = [infoDictionary valueForKey:@"Name"];
            self.secondLabel.hidden = NO;
            self.secondImageView.hidden = NO;
        }
        else if (i ==2) {
            [self setThirdValue:[[infoDictionary valueForKey:@"Value"] floatValue]];
            self.thirdLabel.text = [infoDictionary valueForKey:@"Name"];
            self.thirdLabel.hidden = NO;
            self.thirdImageView.hidden = NO;
        }
        else if (i ==3) {
            [self setFourthValue:[[infoDictionary valueForKey:@"Value"] floatValue]];
            self.fourthLabel.text = [infoDictionary valueForKey:@"Name"];
            self.fourthLabel.hidden = NO;
            self.fourthImageView.hidden = NO;
        }
        else {
            [self setFifthValue:[[infoDictionary valueForKey:@"Value"] floatValue]];
            self.fifthLabel.text = [infoDictionary valueForKey:@"Name"];
            self.fifthImageView.hidden = NO;
            self.fifthLabel.hidden = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helpers

- (float)roundedFloatFromValue:(float)value
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:1];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    
    float result = [[formatter stringFromNumber:[NSNumber numberWithFloat:value]] floatValue];
    
    return result;
}

- (void)setupAttributeView:(UIImageView *)imageView withFloatValue:(float)value
{
    //formula for calculating size
    
    //proportion
    // 300 = 10;       x = (300 * value)/ 10;
    //  x  = value;
    
    //maximum 300
    if (value < 0.5f)
        imageView.hidden = YES;
    else
        imageView.hidden = NO;
    
    CGRect frame = imageView.frame;
    frame.size.width = round((value * 300.0f) /10.0f);
    imageView.frame = frame;
    
}

@end
