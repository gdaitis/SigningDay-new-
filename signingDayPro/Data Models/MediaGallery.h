//
//  MediaGallery.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaItem, User;

@interface MediaGallery : NSManagedObject

@property (nonatomic, retain) NSNumber * galleryType;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSSet *mediaItems;
@property (nonatomic, retain) User *user;
@end

@interface MediaGallery (CoreDataGeneratedAccessors)

- (void)addMediaItemsObject:(MediaItem *)value;
- (void)removeMediaItemsObject:(MediaItem *)value;
- (void)addMediaItems:(NSSet *)values;
- (void)removeMediaItems:(NSSet *)values;

@end
