//
//  ImageData.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 6/27/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageData : NSManagedObject

@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSData * fileData;

@end
