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

static CGRect initialTextFieldFrame;

- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    // Store the initial frame for the the text field
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        initialTextFieldFrame = self.textField.frame;
    });
    
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
            
            [txtField setBackground:nil];
            [txtField setTextColor:[UIColor lightGrayColor]];
            [txtField setFont:[UIFont fontWithName:@"Helvetica-Regular" size:15]];
            [txtField setReturnKeyType:UIReturnKeyDone];
            UIImage *image = [UIImage imageNamed: @"LandingPageSearchBarMagnifyIcon.png"];
            UIImageView *iView = [[UIImageView alloc] initWithImage:image];
            txtField.leftView = iView;
        }
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [view removeFromSuperview];
        }
    }
    
    return txtField;
}

@end
