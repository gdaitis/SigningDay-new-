//
//  SDSearchBar.m
//  signingDayPro
//
//  Created by Lukas Kekys on 5/23/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDSearchBar.h"
#define kSlidingViewPadding 44

@interface SDSearchBar()

@property (readonly) UITextField *textField;

@end

@implementation SDSearchBar

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
    
    int width = initialTextFieldFrame.size.width - (kSlidingViewPadding + 6);
    CGRect newFrame = CGRectMake (self.textField.frame.origin.x,
                                  self.textField.frame.origin.y,
                                  width,
                                  self.textField.frame.size.height);
    
    self.textField.frame = newFrame;
    
    
}

-(UITextField *)textField{
    UITextField *txtField = nil;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass: [UITextField class]]){
            txtField = (UITextField *)view;
            [txtField setBackground:[UIImage imageNamed:@"SearchFieldBg.png"]];
            [txtField setTextColor:[UIColor lightGrayColor]];
            [txtField setFont:[UIFont fontWithName:@"Helvetica-Regular" size:15]];
            UIImage *image = [UIImage imageNamed: @"MagnifyingIcon.png"];
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
