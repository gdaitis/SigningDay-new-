//
//  MediaGallery.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 10/4/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaItem, User;

@interface MediaGallery : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * galleryType;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *mediaItems;
@end

@interface MediaGallery (CoreDataGeneratedAccessors)

- (void)addMediaItemsObject:(MediaItem *)value;
- (void)removeMediaItemsObject:(MediaItem *)value;
- (void)addMediaItems:(NSSet *)values;
- (void)removeMediaItems:(NSSet *)values;

@end
