//
//  ImageData.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 8/14/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageData : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * urlString;

@end
