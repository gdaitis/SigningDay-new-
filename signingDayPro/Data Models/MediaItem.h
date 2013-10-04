//
//  MediaItem.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 10/4/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MediaItem : NSManagedObject

@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * fileUrl;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject *mediaGallery;

@end