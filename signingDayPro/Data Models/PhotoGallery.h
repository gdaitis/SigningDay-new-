//
//  PhotoGallery.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 10/3/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface PhotoGallery : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) User *user;

@end
