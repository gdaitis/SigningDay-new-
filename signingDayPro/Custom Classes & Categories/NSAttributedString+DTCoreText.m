//
//  NSAttributedString+DTCoreText.m
//  SigningDay
//
//  Created by Lukas Kekys on 11/20/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "NSAttributedString+DTCoreText.h"
#import <DTCoreTextLayouter.h>

@implementation NSAttributedString (DTCoreText)

- (CGSize)attributedStringSizeForWidth:(float)width
{
    //height calculation (boundingRectWithSize for DTCoreText doesn't work at time of writing)
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:self];
    CGRect maxRect = CGRectMake(0, 0, width, CGFLOAT_HEIGHT_UNKNOWN);
    NSRange entireString = NSMakeRange(0, [self length]);
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:maxRect range:entireString];
    CGSize sizeNeeded = [layoutFrame frame].size;
    
    return sizeNeeded;
}


@end
