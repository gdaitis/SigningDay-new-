//
//  ImageData.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageData : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * urlString;

@end
