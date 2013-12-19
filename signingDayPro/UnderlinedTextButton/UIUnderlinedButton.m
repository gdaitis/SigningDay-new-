//
//  UIUnderlinedButton.m
//  smecta
//
//  Created by Lukas Kekys on 12/13/12.
//  Copyright (c) 2012 Lukas Kekys. All rights reserved.
//

#import "UIUnderlinedButton.h"

@implementation UIUnderlinedButton


- (void) drawRect:(CGRect)rect
{
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender+3);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender+3);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}


@end
