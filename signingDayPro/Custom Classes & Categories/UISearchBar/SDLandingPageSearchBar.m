//
//  SDSearchBar.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/23/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDLandingPageSearchBar.h"

#define kSlidingViewPadding 44

@interface SDLandingPageSearchBar()

@property (readonly) UITextField *textField;

@end

@implementation SDLandingPageSearchBar

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self updateTextFieldFrame];
}

-(void)updateTextFieldFrame{
    
    CGRect newFrame = CGRectMake (10,
                                  7,
                                  300, //10 px offset from both sides
                                  self.textField.frame.size.height);
    
    self.textField.frame = newFrame;
}

-(UITextField *)textField{
    UITextField *txtField = nil;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass: [UITextField class]]){
            txtField = (UITextField *)view;
            
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LandingPageSearchBackground.png"]];
            CGRect frame = imageView.frame;
            frame.origin.y = -8;
            imageView.frame = frame;
            txtField.clipsToBounds = NO;
            
            [txtField addSubview:imageView];
            [txtField sendSubviewToBack:imageView];
            
//            txtField.backgroundColor = [UIColor whiteColor];
//            txtField.layer.cornerRadius = 5.0f;
//            txtField.clipsToBounds = YES;
//            txtField.layer.borderWidth = 1.0f;
//            txtField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            
            [txtField setBackground:nil];
            [txtField setTextColor:[UIColor lightGrayColor]];
            [txtField setFont:[UIFont fontWithName:@"Helvetica-Regular" size:15]];
            [txtField setReturnKeyType:UIReturnKeySearch];
            
//            UIImage *image = [UIImage imageNamed: @"LandingPageSearchBarMagnifyIcon.png"];
//            UIImageView *iView = [[UIImageView alloc] initWithImage:image];
//            txtField.leftView = iView;
        }
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [view removeFromSuperview];
        }
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)view;
            cancelButton.enabled = YES;
            [cancelButton setBackgroundImage:Nil forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:Nil forState:UIControlStateHighlighted];
            
            [cancelButton setTitle:@"" forState:UIControlStateHighlighted];
            [cancelButton setTitle:@"" forState:UIControlStateNormal];
            
            [cancelButton setImage:nil forState:UIControlStateNormal];
            [cancelButton setImage:nil forState:UIControlStateHighlighted];
            cancelButton.userInteractionEnabled = NO;
            break;
        }
    }
    
    return txtField;
}

@end
