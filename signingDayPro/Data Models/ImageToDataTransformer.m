//
//  ImageToDataTransformer.m
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/27/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "ImageToDataTransformer.h"

@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

+ (Class)transformedValueClass
{
	return [NSData class];
}


- (id)transformedValue:(id)value
{
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value
{
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}

@end
